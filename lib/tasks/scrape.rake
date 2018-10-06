namespace :scrape do
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'
  require 'date'
  task senators: :environment do
    @doc = Nokogiri::HTML(open("https://www.nysenate.gov/senators-committees"))
    senators = @doc.css(".c-senator-block")
    senators.each do |senator|
      name = senator.css(".nys-senator--name").text
      full_name = name
      first_name = full_name.split(" ")[0]
      mi = nil
      suffix = nil
      last_name = full_name.split(" ").last
      url = "https://www.nysenate.gov/senators/#{first_name}-#{last_name}"
      if full_name.split(" ").count == 3
        mi = full_name.split(" ")[1].chomp(".")
        url = "https://www.nysenate.gov/senators/#{first_name}-#{mi}-#{last_name}"
      elsif full_name.split(" ").count == 4
        suffix = last_name.chomp(".")
        mi = full_name.split(" ")[1].chomp(".")
        last_name = full_name.split(" ")[full_name.split(" ").count - 2]
        url = "https://www.nysenate.gov/senators/#{first_name}-#{mi}-#{last_name}-#{suffix}"
      end
      email = "#{last_name}@nysenate.gov"
      img = senator.css("img").attr('src')
      party = senator.css(".nys-senator--party").text.strip
      district = senator.css(".nys-senator--district").text.split(")")[1].strip
      senator = Senator.new(name: name, url: url, email: email, party: party, district: district, img: img, rating: "?")
      senator.save()
    end
  end

  task donations: :environment do
    agent = Mechanize.new
    form_page = agent.get('https://www.elections.ny.gov/ContributionSearchA.html')
    form = form_page.forms[1]
    Senator.all.each do |senator|
      puts "################################################"
      puts "################################################"
      puts senator.name
      last_name = ""
      if senator.name.split(" ").last[-1] == "."
        names = senator.name.split(" ")
        last_name = names[names.length-2]
      elsif senator.name.split(" ").length == 4
        names = senator.name.split(" ")
        last_name = names[names.length-2]
      else
        last_name = senator.name.split(" ").last
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
          year = row.search("td").children.text.scan(/19|20\d{2}\b/)
          name = row.search("td").children.text.split("\n")[0].to_s.strip.chop
          value = "$" + row.search("td").children.text.scan(/(\d+\,)?(\d+\.\d\d)/).join
          # Lobbyist.all.each do |lobbyist|
          #   if name.include? lobbyist.name
          #     puts lobbyist.name
          #     donation = Donation.new(senator_id: senator.id, lobbyist_id: lobbyist.id, value: value, year: year)
          #     donation.save()
          #     senator.donations.push(donation)
          #     senator.save
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
                donation = Donation.new(senator_id: senator.id, lobbyist_id: lobbyist.id, value: value, year: y)
                donation.save()
                senator.donations.push(donation)
                senator.save
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
    sponsor = Senator.where(name: sponsor).take
    puts sponsor
    puts "\ncosponsor:"
    cosponsor_name = @doc.css(".initial_co-sponsors a").text
    cosponsor = Senator.where(name: sponsor).take
    puts cosponsor
    if passed_senate
      puts "\npassed senate"
      puts "\naye votes:"
      aye_votes = @doc.css(".c-bill--vote_1 .c-votes--items")[0].css("a")
      aye_votes.each do |vote|
        name = vote.text
        senator = Senator.where("name ~* ?", name).first
        unless senator.nil?
          puts senator.name
        end
      end
      puts "\nnay votes:"
      nay_votes = @doc.css(".c-bill--vote_1 .c-votes--items")[1].css("a")
      nay_votes.each do |vote|
        name = vote.text
        senator = Senator.where("name ~* ?", name).first
        unless senator.nil?
          puts senator.name
        end
      end
    elsif in_commitee
      puts "\nin commitee"
      puts "\naye votes:"
      aye_votes = @doc.css(".c-bill--vote_2 .c-votes--items")[0].css("a")
      aye_votes.each do |vote|
        name = vote.text
        senator = Senator.where("name ~* ?", name).first
        unless senator.nil?
          puts senator.name
        end
      end
      puts "\nnay votes:"
      nay_votes = @doc.css(".c-bill--vote_2 .c-votes--items")[1].css("a")
      nay_votes.each do |vote|
        name = vote.text
        senator = Senator.where("name ~* ?", name).first
        unless senator.nil?
          puts senator.name
        end
      end
    end
    puts "\nunknown votes:"
    Senator.all.each do |senator|
        unless vote.bill_id == bill_id
          puts senator.name
        end
    end
  end
end
