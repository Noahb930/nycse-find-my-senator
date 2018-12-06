namespace :scrape do
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'
  require 'date'
  require 'json'
  require 'geocoder'
  require 'geokit'


  task senators: :environment do
    @doc = Nokogiri::HTML(open("https://www.nysenate.gov/senators-committees"))
    representatives = @doc.css(".c-senator-block")
    representatives.each do |representative|
      name = representative.css(".nys-senator--name").text
      img = representative.css("img").attr('src')
      party = representative.css(".nys-senator--party").text.strip
      district = representative.css(".nys-senator--district").text.split(")")[1].strip
      representative = Representative.new(name: name, party: party, district: district, img: img, rating: "?", profession: "NY State Senator")
      puts representative
      representative.save()
    end
  end
  task assembly: :environment do
    require 'nokogiri'
    require 'open-uri'
    @doc = Nokogiri::HTML(open("http://nyassembly.gov/mem/"))
    members = @doc.css(".mem-leader")
    members.each do |member|
      url = "http://nyassembly.gov#{member.css("strong a").attr("href")}"
      img = "http://nyassembly.gov#{member.css("img").attr("src")}"
      name = member.css("strong a").text
      profession = "NY State Assembly Member"
      district = member.css("strong").text.split("--")[1].strip
      email = member.css(".mem-email a").text
      representative = Representative.new(name: name,url: url, profession: profession, email: email, district: district, img: img,rating: "?",party: "?")
      representative.save()
    end
  end
  task test1: :environment do
    agent = Mechanize.new { |a|
  # Flickr refreshes after login
  a.follow_meta_refresh = true
}
    page = agent.get('https://assembly.state.ny.us/mem/search/')
    form = page.forms[0]
      form.field_with(:name => 'gmap_street').value = "125 e 87"
      form.field_with(:name => 'gmap_city').value = "new york"
      form.field_with(:name => 'gmap_zip').value = "10128"
    mem_page =form.submit

    # pp page
    # puts "\n"
    # pp mem_page
    name = mem_page.css("#mem-name a")
    puts name.text
  end
  task test3: :environment do
    address = "125 e 87"
    address.gsub!(' ', '%20')
    browser = Watir::Browser.new :chrome, headless: true
    puts "http://www.elections.ny.gov/district-map/district-map.html#/?address=#{address}&radius=1"
    browser.goto("http://www.elections.ny.gov/district-map/district-map.html#/?address=#{address}&radius=1")
    pp browser.links
    browser.div(id: "boxesass").wait_until {puts "yctuvib"}
    # .element(tag_name: 'strong').
    # browser.css("#boxesass strong").when_present {puts "xtcryvugibhon"}

  end
  task test4: :environment do
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto("https://nyassembly.gov/mem/search/")
    browser.text_field(:name, "gmap_street").set '125 e 87'
    browser.text_field(:name, "gmap_city").set 'new york'
    browser.text_field(:name, "gmap_zip").set '10128'
    btn = browser.button value: 'Locate'
    btn.click
    sleep 5
    pp browser.div(id: "mem-name").links[0].text
    end
  task test2: :environment do
    agent = Mechanize.new
    page = agent.get("https://council.nyc.gov/districts/")
    form = page.forms[0]
    form.field_with(:id => 'list-search-input').value = "125 e 87"
    rep_page = form.submit
    pp rep_page
    # pp page
    # puts "\n"
    # pp mem_page
  end
  task test5: :environment do
    district = ""
    address = "125 e 87"
    city = "New York"
    zip = "10128"
    results = Geocoder.search("#{address}, #{city} #{zip}")
    latlng = results.first.coordinates
    loc =  Geokit::LatLng.new(latlng[0], latlng[1])
    file = File.read('admaps.json').downcase
    maps = JSON.parse(file)
    output = []
    maps["ad"].each do |map|
      district = "District " + map["features"][0]["properties"]["district"].to_s
      points = []
      if map["features"][0]["geometry"]["type"] == "polygon"
        map["features"][0]["geometry"]["coordinates"][0].each do |point|
          points << Geokit::LatLng.new(point[1], point[0])
        end
        polygon = Geokit::Polygon.new(points)
      else
        map["features"][0]["geometry"]["coordinates"][0].each do |shape|
          shape.each do |point|
            points << Geokit::LatLng.new(point[0], point[1])
          end
        end
        polygon = Geokit::Polygon.new(points)
      end
      if polygon.contains? loc
        puts district
        break
      end
      obj = {district: district, polygon: polygon}
      output.push(obj)
    end
    # file = File.open("maps.rb", 'w')
    # file.write("require 'geokit'\n")
    # file.write("assembly_map = ")
    # file.write(output)
    rep = Representative.where(profession:"NY State Assembly Member").where(district: district).first
    puts rep
  end
  task donations: :environment do
    agent = Mechanize.new
    form_page = agent.get('https://www.elections.ny.gov/ContributionSearchA.html')
    form = form_page.forms[1]
    Representative.all.each do |representative|
      puts "################################################"
      puts "################################################"
      puts representative.name
      last_name = ""
      if representative.name.split(" ").last[-1] == "."
        names = representative.name.split(" ")
        last_name = names[names.length-2]
      elsif representative.name.split(" ").length == 4
        names = representative.name.split(" ")
        last_name = names[names.length-2]
      else
        last_name = representative.name.split(" ").last
      end
      form.field_with(:name => 'NAME_IN').value = last_name
      form.field_with(:name => 'date_from').value = "1/1/1950"
      form.field_with(:name => 'date_to').value = Time.now.strftime("%m/%d/%Y")
      form.field_with(:name => 'AMOUNT_from').value = 0
      form.field_with(:name => 'CATEGORY_IN').value = "OTHER"
      form.field_with(:name => 'AMOUNT_to').value = 10000
      funds_page = agent.submit(form)
      links = funds_page.links[3..funds_page.links.length-2]
      links.each do |link|
        donations_page = link.click
        rows = donations_page.search("tr")
        rows[1..rows.length - 2].each do |row|
          year = row.search("td").children.text.scan(/(?:19|20)\d{2}\b/)
          name = row.search("td").children.text.split("\n")[0].to_s.strip.chop
          value = "$" + row.search("td").children.text.scan(/(\d+\,)?(\d+\.\d\d)/).join
          # Lobbyist.all.each do |lobbyist|
          #   if name.include? lobbyist.name
          #     puts lobbyist.name
          #     donation = Donation.new(representative_id: representative.id, lobbyist_id: lobbyist.id, value: value, year: year)
          #     donation.save()
          #     representative.donations.push(donation)
          #     representative.save
          #     lobbyist.donations.push(donation)
          #     lobbyist.save()
          #   end
          # end
          year.each do |y|
            unless y.to_i>2018
              if ((name.include? "GUN " )|| (name.include? "RIFLE ") || (name.include? "NRA "))&&(name.exclude? "CONTROL")&&(name.exclude? "VIOLENCE")&&(name.exclude? "SAFETY")&&(name.exclude? "GUN HILL")
                puts name
                lobbyist = Lobbyist.new(name: name)
                unless Lobbyist.where(name: name).length >0
                  lobbyist.save()
                else
                  lobbyist = Lobbyist.where(name: name)[0]
                end
                donation = Donation.new(representative_id: representative.id, lobbyist_id: lobbyist.id, value: value, year: y)
                donation.save()
                representative.donations.push(donation)
                representative.save
                lobbyist.donations.push(donation)
                lobbyist.save()
              end
            end
          end
        end
      end
    end
  end
  task votes: :environment do
    bill_number = "A08976"
    term = "2017"
    doc = Nokogiri::HTML(open("https://nyassembly.gov/leg/?default_fld=&leg_video=&bn=#{bill_number}&term=#{term}&Summary=Y&Floor%26nbspVotes=Y"))
    rows = doc.css("table")[0].css("tr")
    sponsor = rows[4].css("td")[1].text
    cosponsors = rows[6].css("td")[1].text.split(",").collect{|x| x.strip || x }
    rows = doc.css("table")[1].css("tr")
    aye = []
    nay = []
    er = []
    rows.each do |row|
      if row.css("td")[1].text == "Y"
        aye.push(row.css("td")[0].text)
      elsif row.css("td")[1].text == "NO"
        nay.push(row.css("td")[0].text)
      elsif row.css("td")[1].text == "ER"
        er.push(row.css("td")[0].text)
      end
      if row.css("td")[3].text == "Y"
        aye.push(row.css("td")[2].text)
      elsif row.css("td")[3].text == "NO"
        nay.push(row.css("td")[2].text)
      elsif row.css("td")[3].text == "ER"
        er.push(row.css("td")[2].text)
      end
      if row.css("td")[5].text == "Y"
        aye.push(row.css("td")[4].text)
      elsif row.css("td")[5].text == "NO"
        nay.push(row.css("td")[4].text)
      elsif row.css("td")[5].text == "ER"
        er.push(row.css("td")[4].text)
      end
      if row.css("td")[7].text == "Y"
        aye.push(row.css("td")[6].text)
      elsif row.css("td")[7].text == "NO"
        nay.push(row.css("td")[6].text)
      elsif row.css("td")[7].text == "ER"
        er.push(row.css("td")[6].text)
      end
      if row.css("td")[9].text == "Y"
        aye.push(row.css("td")[8].text)
      elsif row.css("td")[9].text == "NO"
        nay.push(row.css("td")[8].text)
      elsif row.css("td")[9].text == "ER"
        er.push(row.css("td")[8].text)
      end
      if row.css("td")[11].text == "Y"
        aye.push(row.css("td")[10].text)
      elsif row.css("td")[11].text == "NO"
        nay.push(row.css("td")[10].text)
      elsif row.css("td")[11].text == "ER"
        er.push(row.css("td")[10].text)
      end
    end
    aye  = aye - (aye & cosponsors)
    er = er - (er & cosponsors)
    puts aye.length
    puts nay.length
    puts er.length
    puts cosponsors.length
    aye.each do |rep|
      Representative.where("name like ?", "%#{rep.strip}%")
    end
  end
end
