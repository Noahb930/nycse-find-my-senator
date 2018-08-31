namespace :scrape do
  desc "Scrape NY senators and add them to db"
  task NY_senators: :environment do
    require 'nokogiri'
    require 'open-uri'
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
  desc "Scrape NY State assembly members and add them to db"
  task NY_assembly: :environment do
    require 'nokogiri'
    require 'open-uri'
    @doc = Nokogiri::HTML(open("http://nyassembly.gov/mem/"))
    members = @doc.css(".mem-leader")
    members.each do |member|
      url = "http://nyassembly.gov#{member.css("strong a").attr("href")}"
      img = "http://nyassembly.gov#{member.css("img").attr("src")}"
      full_name = member.css("strong a").text
      profession = "New York State Assembly Member"
      first_name = full_name.split(" ")[0]
      district = member.css("strong").text.split("--")[1].strip
      mi = nil
      suffix = nil
      last_name = full_name.split(" ").last
      if full_name.split(" ").count == 3
        mi = full_name.split(" ")[1].chomp(".")
      elsif full_name.split(" ").count == 4
        suffix = last_name.chomp(".")
        mi = full_name.split(" ")[1].chomp(".")
        last_name = full_name.split(" ")[full_name.split(" ").count - 2]
      end
      email = member.css(".mem-email a").text
      district_office = member.css(".full-addr.float-left").text
      district_office_phone = district_office.match(/[^:]\d{3}-\d{3}-\d{4}/).to_s
      district_office_address = district_office.split(district_office_phone)[0]
      district_office_fax = district_office.match(/[:]\d{3}-\d{3}-\d{4}/).to_s.sub(":","")
      albany_office = member.css(".full-addr.float-right").text
      albany_office_phone = albany_office.match(/[^:]\d{3}-\d{3}-\d{4}/).to_s
      albany_office_address = albany_office.split(district_office_phone)[0]
      albany_office_fax = albany_office.match(/[:]\d{3}-\d{3}-\d{4}/).to_s.sub(":","")
      representative = Representative.new(first_name: first_name, last_name: last_name, MI: mi, suffix: suffix, full_name: full_name,
         url: url, profession: profession, email: email, district: district, img: img,
          district_office_phone: district_office, district_office_address: district_office_address, district_office_fax: district_office_fax,
        albany_office_phone: albany_office_phone, albany_office_address: albany_office_address, albany_office_fax: albany_office_fax)
      representative.save()
    end
  end

end
