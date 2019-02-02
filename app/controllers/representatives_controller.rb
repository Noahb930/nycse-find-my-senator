require 'nokogiri'
require 'open-uri'
require 'sendgrid-ruby'
require 'geokit'
class RepresentativesController < ApplicationController
      before_action :set_representative, only: [:show, :edit, :update, :destroy]
  USERS = { ENV['USERNAME'] => ENV['PASSWORD'] }
  before_action :authenticate, except: [:index, :show, :find, :votes, :donations, :contact]
  def find
    address=params[:address]
    city=params[:city]
    zip=params[:zipcode]
    @reps = []
    Representative.where(profession:"US Senator").each do |rep|
      @reps.push(rep)
    end

    district = ""
    results = Geocoder.search("#{address}, #{city} #{zip}")
    latlng = results.first.coordinates
    loc =  Geokit::LatLng.new(latlng[0], latlng[1])
    file = File.read("house_map.json").downcase
    maps = JSON.parse(file)
    maps["features"].each do |map|
      district = "District " + map["properties"]["district"].to_s
      points = []
      if map["geometry"]["type"] == "polygon"
        map["geometry"]["coordinates"][0].each do |point|
          points << Geokit::LatLng.new(point[1], point[0])
        end
        polygon = Geokit::Polygon.new(points)
      else
        map["geometry"]["coordinates"][0].each do |shape|
          shape.each do |point|
            points << Geokit::LatLng.new(point[0], point[1])
          end
        end
        polygon = Geokit::Polygon.new(points)
      end
      if polygon.contains? loc
        puts district
        rep = Representative.where(profession:"Member of The US House of Representatives").where(district: district).first
        unless rep.nil?
          @reps.push(rep)
        end
        break
      end
    end
    file = File.read('state_senate_map.json').downcase
    maps = JSON.parse(file)
    maps["features"].each do |map|
      district = "District " + map["properties"]["district"].to_s
      points = []
      if map["geometry"]["type"] == "polygon"
        map["geometry"]["coordinates"][0].each do |point|
          points << Geokit::LatLng.new(point[1], point[0])
        end
        polygon = Geokit::Polygon.new(points)
      else
        map["geometry"]["coordinates"][0].each do |shape|
          shape.each do |point|
            points << Geokit::LatLng.new(point[0], point[1])
          end
        end
        polygon = Geokit::Polygon.new(points)
      end
      if polygon.contains? loc
        rep = Representative.where(profession:"NY State Senator").where(district: district).first
        unless rep.nil?
          @reps.push(rep)
        end
        break
      end
    end
    file = File.read('assembly_map.json').downcase
    maps = JSON.parse(file)
    maps["features"].each do |map|
      district = "District " + map["properties"]["district"].to_s.sub(/^[0]+/,'')
      points = []
      if map["geometry"]["type"] == "polygon"
        map["geometry"]["coordinates"][0].each do |point|
          points << Geokit::LatLng.new(point[1], point[0])
        end
        polygon = Geokit::Polygon.new(points)
      else
        map["geometry"]["coordinates"][0].each do |shape|
          shape.each do |point|
            points << Geokit::LatLng.new(point[0], point[1])
          end
        end
        polygon = Geokit::Polygon.new(points)
      end
      if polygon.contains? loc
        rep = Representative.where(profession:"NY State Assembly Member").where(district: district).first
        unless rep.nil?
          @reps.push(rep)
        end
        break
      end
    end
    respond_to do |format|
      format.html { render :view}
    end
  end
  def admin_state_assembly_index
  end
  def admin_house_index
  end
  def admin_senate_index
  end
  def show
    @representative = Representative.find(params[:id])
    @index = params[:index]
    respond_to do |format|
      format.js
    end
  end
  def votes
    @representative = Representative.find(params[:id])
    @index = params[:index]
    respond_to do |format|
      format.js
    end
  end
  def donations
    @representative = Representative.find(params[:id])
    @index = params[:index]
    respond_to do |format|
      format.js
    end
  end
  def contact
    @representative = Representative.find(params[:id])
    @index = params[:index]
    respond_to do |format|
      format.js
    end
  end
  def mail
    @representative =  Representative.find(params[:id])
    from_email = params[:from_email]
    from = SendGrid::Email.new(email: from_email)
    to = SendGrid::Email.new(email: @representative.email)
    subject = params[:subject]
    content = SendGrid::Content.new(type: 'text/plain', value: "Dear Representative #{@representative.name},\n #{params[:message]} \nSincerely,\n #{params[:name]}")
    mail = SendGrid::Mail.new(from, subject, to, content)
    puts mail.to_json
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
  # GET /representatives
  # GET /representatives.json
  def index
    @representatives = Representative.all
  end

  # GET /representatives/1
  # GET /representatives/1.json

  def admin_index
    @representatives = Representative.all
  end

  # GET /representatives/1
  # GET /representatives/1.json
  def admin_show
    @representative = Representative.find(params[:id])
  end
  # GET /representatives/new
  def new
    @representative = Representative.new
  end



  def admin_votes
    @representative = Representative.find(params[:id])
  end
  def admin_donations
    @representative = Representative.find(params[:id])
    @donation = Donation.new
  end

  # POST /representatives
  # POST /representatives.json
  def create
    @representative = Representative.new(representative_params)

    respond_to do |format|
      if @representative.save
        format.html { redirect_to @representative, notice: 'Representative was successfully created.' }
        format.json { render :show, status: :created, location: @representative }
      else
        format.html { render :new }
        format.json { render json: @representative.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /representatives/1
  # PATCH/PUT /representatives/1.json
  def update
    respond_to do |format|
      if @representative.update(representative_params)
        format.html { redirect_to @representative, notice: 'Representative was successfully updated.' }
        format.json { render :show, status: :ok, location: @representative }
      else
        format.html { render :edit }
        format.json { render json: @representative.errors, status: :unprocessable_entity }
      end
    end
  end
  def edit
    @representative = Representative.find(params[:id])
  end
  # DELETE /representatives/1
  # DELETE /representatives/1.json
  def destroy
    @representative.destroy
    respond_to do |format|
      format.html { redirect_to representatives_url, notice: 'Representative was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_representative
    @representative = Representative.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def representative_params
    params.require(:representative).permit(:name, :email, :party, :beliefs, :rating, :img, :district, :url, :profession)
  end
  def authenticate
    authenticate_or_request_with_http_digest do |username|
      USERS[username]
    end
  end
end
