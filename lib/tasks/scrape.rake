namespace :scrape do
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'
  require 'date'
  task senators: :environment do
    @doc = Nokogiri::HTML(open("https://www.nysenate.gov/representatives-committees"))
    representatives = @doc.css(".c-representative-block")
    representatives.each do |representative|
      name = representative.css(".nys-representative--name").text
      url = "https://www.nysenate.gov/representatives/#{first_name}-#{last_name}"
      email = "#{last_name}@nysenate.gov"
      img = representative.css("img").attr('src')
      party = representative.css(".nys-representative--party").text.strip
      district = representative.css(".nys-representative--district").text.split(")")[1].strip
      representative = Representative.new(name: name, url: url, email: email, party: party, district: district, img: img, rating: "?", profession: "NY State Senator")
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
      representative = Representative.new(name: name,url: url, profession: profession, email: email, district: district, img: img)
      representative.save()
    end
  end
  task test1: :environment do
    agent = Mechanize.new
    page = agent.get('https://assembly.state.ny.us/mem/search/')
    form = page.forms[0]
    form.field_with(:name => 'gmap_street').value = "125 e 87"
    form.field_with(:name => 'gmap_city').value = "new york"
    form.field_with(:name => 'gmap_zip').value = "10128"
    mem_page = agent.submit(form)
    pp page
    puts "\n"
    pp mem_page
    name = mem_page.css("#mem-name a")
    pp name.text
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

    @doc = Nokogiri::HTML(open(""))
    bill_id = bill.id
    passed_senate = @doc.css(".nys-bill-status li")[4].attr('class') == "passed"
    puts @doc.css(".passed")[1].attr('class')
    in_commitee = @doc.css(".passed")[1].attr('class') == "passed"
    puts "sponsor:"
    sponsor_name = @doc.css(".c-sponsor a").text
    sponsor = Representative.where(name: sponsor).take
    puts sponsor
    puts "\ncosponsor:"
    cosponsor_name = @doc.css(".initial_co-sponsors a").text
    cosponsor = Representative.where(name: sponsor).take
    puts cosponsor
    if passed_senate
      puts "\npassed senate"
      puts "\naye votes:"
      aye_votes = @doc.css(".c-bill--vote_1 .c-votes--items")[0].css("a")
      aye_votes.each do |vote|
        name = vote.text
        representative = Representative.where("name ~* ?", name).first
        unless representative.nil?
          puts representative.name
        end
      end
      puts "\nnay votes:"
      nay_votes = @doc.css(".c-bill--vote_1 .c-votes--items")[1].css("a")
      nay_votes.each do |vote|
        name = vote.text
        representative = Representative.where("name ~* ?", name).first
        unless representative.nil?
          puts representative.name
        end
      end
    elsif in_commitee
      puts "\nin commitee"
      puts "\naye votes:"
      aye_votes = @doc.css(".c-bill--vote_2 .c-votes--items")[0].css("a")
      aye_votes.each do |vote|
        name = vote.text
        representative = Representative.where("name ~* ?", name).first
        unless representative.nil?
          puts representative.name
        end
      end
      puts "\nnay votes:"
      nay_votes = @doc.css(".c-bill--vote_2 .c-votes--items")[1].css("a")
      nay_votes.each do |vote|
        name = vote.text
        representative = Representative.where("name ~* ?", name).first
        unless representative.nil?
          puts representative.name
        end
      end
    end
    puts "\nunknown votes:"
    Representative.all.each do |representative|
        unless vote.bill_id == bill_id
          puts representative.name
        end
    end
  end
end
