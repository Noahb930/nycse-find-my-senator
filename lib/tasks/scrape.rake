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
  task :congress_orgs,  [:id,:name, :start_year, :end_year] => [:environment] do |t, args|
    agent = Mechanize.new
    lobbyist = Lobbyist.where(name: args[:name]).first
    if lobbyist.nil?
      lobbyist = Lobbyist.new(name: args[:name])
      lobbyist.save()
    end
    (args[:start_year]..args[:end_year]).step(2) do |cycle|
      page = agent.get("https://www.opensecrets.org/orgs/recips.php?id=#{args[:id]}&type=P&cycle=#{cycle.to_s}&sort=A&state=NY")
      rows = page.css('#recips tbody tr')
      rows.each do |row|
        cells = row.css("td")
        value = cells[2].text
        name = cells[0].text.split(" ")
        first = name[1]
        last = name[0].chop()
        puts "#{first} #{last}"
        rep = Representative.where("name like ?", "%#{first}%").where("name like ?", "%#{last}%").first
        puts cells[2].text
        unless rep.nil?
        start_cycle = cycle.to_i - 1
        year = start_cycle.to_s + " - " + cycle.to_s
        donation = Donation.new(representative_id: rep.id, lobbyist_id: lobbyist.id, value: value, year: year)
        donation.save()
        rep.donations.push(donation)
        rep.save
        lobbyist.donations.push(donation)
        lobbyist.save()
      end
      end
    end
  end
  task links: :environment do
    links_obj = Representative.where(name: "links array")[0]
    links_array = links_obj.beliefs.split(" ")
    agent = Mechanize.new
    form_page = agent.get('https://www.elections.ny.gov/ContributionSearchA.html')
    form = form_page.forms[1]
    Representative.where(profession: ["NY State Senator", "NY State Assembly Member"]).where.not("rating like ?", "%A%").each do |representative|
      puts "################################################"
      puts "################################################"
      puts representative.name
      names = representative.name.split(" ")
      last_name = ""
      if names[-1][-1] == "."
        last_name = names[-2]
      else
        last_name = names[-1]
      end
      form.field_with(:name => 'NAME_IN').value = last_name
      form.field_with(:name => 'date_from').value = "01/01/1990"
      form.field_with(:name => 'date_to').value = Time.now.strftime("%m/%d/%Y")
      form.field_with(:name => 'AMOUNT_from').value = 0
      form.field_with(:name => 'CATEGORY_IN').value = "OTHER"
      form.field_with(:name => 'AMOUNT_to').value = 1000000
      funds_page = agent.submit(form)
      links = funds_page.links[3..funds_page.links.length-2]
      links.each_with_index do |link, i|
        puts "Current Representative: " + representative.name
        STDOUT.puts "Check link #{funds_page.css("tr")[i+1].css("td")[0].text}? (y/n)"
        input = STDIN.gets.strip
        if input == 'y'
          puts "checking"
          links_array.push(link.href)
          links_obj.beliefs = links_array.join(" ")
          links_obj.save()
        else
          STDOUT.puts "canceled"
        end
      end
    end
    puts links_array
  end
  task :lobbyists,  [:keywords] => [:environment] do |t, args|
    agent = Mechanize.new
    args[:keywords].split(" ").each do |keyword|
      ["11","12"].each do |office|
        puts "#########################################################"
        puts "#########################################################"
        puts "please wait: searching for lobbyists with the keyword #{keyword}"
        form_page = agent.get('https://www.elections.ny.gov/ContributionSearchB_State_Office.html')
        form = form_page.forms[1]
        form.field_with(:name => 'NAME_IN').value = keyword
        form.field_with(:name => 'position_IN').value = "ANYWHERE"
        form.field_with(:name => 'date_from').value = "01/01/1990"
        form.field_with(:name => 'date_to').value = Time.now.strftime("%m/%d/%Y")
        form.field_with(:name => 'AMOUNT_from').value = 0
        form.field_with(:name => 'AMOUNT_to').value = 100000
        form.field_with(:name => 'OFFICE_IN').value = office
        donations_page = agent.submit(form)
        rows = donations_page.search("tr")
        rows[2..rows.length - 3].each do |row|
          name = row.css("td:first-child font").inner_html.split("<br>")[0].to_s.strip.gsub('amp;', '')
          if Lobbyist.where(name: name).empty?
            STDOUT.puts "Add lobbyist #{name}? (y/n)"
            input = STDIN.gets.strip
            if input == 'y'
              lobbyist = Lobbyist.new(name: name)
              lobbyist.save()
              puts "addded"
            else
              STDOUT.puts "canceled"
            end
          end
        end
      end
    end
  end
  # task state_legislature_contributions: :environment do
  #   agent = Mechanize.new
  #   form_page = agent.get('https://www.elections.ny.gov/ContributionSearchA.html')
  #   form = form_page.forms[1]
  #   Representative.where(profession: ["NY State Senator", "NY State Assembly Member"]).where.not("rating like ?", "%A%").each do |representative|
  #     puts "################################################"
  #     puts "################################################"
  #     puts representative.name
  #     names = representative.name.split(" ")
  #     last_name = ""
  #     if names[-1][-1] == "."
  #       last_name = names[-2]
  #     else
  #       last_name = names[-1]
  #     end
  #     form.field_with(:name => 'NAME_IN').value = last_name
  #     form.field_with(:name => 'date_from').value = "01/01/1990"
  #     form.field_with(:name => 'date_to').value = Time.now.strftime("%m/%d/%Y")
  #     form.field_with(:name => 'AMOUNT_from').value = 0
  #     form.field_with(:name => 'CATEGORY_IN').value = "OTHER"
  #     form.field_with(:name => 'AMOUNT_to').value = 1000000
  #     funds_page = agent.submit(form)
  #     links = funds_page.links[3..funds_page.links.length-2]
  #     links.each_with_index do |link, i|
  #       puts "Current Representative: " + representative.name
  #       STDOUT.puts "Check link #{funds_page.css("tr")[i+1].css("td")[0].text}? (y/n)"
  #       input = STDIN.gets.strip
  #       if input == 'y'
  #         puts "checking"
  #         donations_page = link.click
  #         rows = donations_page.search("tr")
  #         rows[2..-2].each do |row|
  #           year = row.css("td")[2].text.split("-")[2].to_i
  #           if year > 20
  #             year = "19"+year.to_s
  #           else
  #             year = "20"+year.to_s
  #           end
  #           name = row.search("td").children.text.split("\n")[0].to_s.strip.chop
  #           puts name
  #           value = "$" + /(?!\.)[1-9](\d)+(\,\d{3})*/.match(name).to_s
  #           Lobbyist.all.each do |lobbyist|
  #             if name == lobbyist.name
  #               puts lobbyist.name
  #               donation = Donation.new(representative_id: representative.id, lobbyist_id: lobbyist.id, value: value, year: year)
  #               donation.save()
  #               representative.donations.push(donation)
  #               representative.save
  #               lobbyist.donations.push(donation)
  #               lobbyist.save()
  #             end
  #           end
  #         end
  #       else
  #         STDOUT.puts "canceled"
  #       end
  #     end
  #   end
  # end
  task state_legislature_contributions: :environment do
    links_array = Representative.where(name: "links array")[0].beliefs.split(" ")
    links_array.each do |link|
      agent = Mechanize.new
      url = "http://www.elections.ny.gov:8080"+link
      donations_page = agent.get('https://www.elections.ny.gov/ContributionSearchA.html')
      rows = donations_page.search("tr")
      rows[2..-2].each do |row|
        year = row.css("td")[2].text.split("-")[2].to_i
        if year > 20
          year = "19"+year.to_s
        else
          year = "20"+year.to_s
        end
        name = row.search("td").children.text.split("\n")[0].to_s.strip.chop
        puts name
        value = "$" + /(?!\.)[1-9](\d)+(\,\d{3})*/.match(name).to_s
        Lobbyist.all.each do |lobbyist|
          if name == lobbyist.name
            puts lobbyist.name
            donation = Donation.new(representative_id: representative.id, lobbyist_id: lobbyist.id, value: value, year: year)
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
