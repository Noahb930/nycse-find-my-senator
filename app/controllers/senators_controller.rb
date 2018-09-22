require 'nokogiri'
require 'open-uri'
require 'sendgrid-ruby'
class SenatorsController < ApplicationController
  before_action :set_senator, only: [:show, :edit, :update, :destroy]
  USERS = { ENV['USERNAME'] => ENV['PASSWORD'] }
  before_action :authenticate, except: [:index, :show, :find, :votes, :donations, :contact]
  def find
    address = params[:address]
    city = params[:city]
    zipcode = params[:zipcode]
    doc = Nokogiri::HTML(open("https://www.nysenate.gov/find-my-senator?search=true&addr1=#{address}&city=#{city}&zip5=#{zipcode}"))
    name = doc.css(".c-find-my-senator--district-info .c-find-my-senator--senator-link").text.squish
    if name==""
      flash[:danger] = "Address is not valid, please try again"
      redirect_to '/'
    else
      senator = Senator.where(name: name)
      redirect_to "/senators/#{senator[0].id}"
    end
  end
  def mail
    @senator =  Senator.find(params[:id])
    from_email = params[:from_email]
    from = SendGrid::Email.new(email: from_email)
    to = SendGrid::Email.new(email: @senator.email)
    subject = params[:subject]
    content = SendGrid::Content.new(type: 'text/plain', value: "Dear Senator #{@senator.name},\n #{params[:message]} \nSincerely,\n #{params[:name]}")
    mail = SendGrid::Mail.new(from, subject, to, content)
    puts mail.to_json
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
  # GET /senators
  # GET /senators.json
  def index
    @senators = Senator.all
  end

  # GET /senators/1
  # GET /senators/1.json
  def show
  end
  def admin_index
    @senators = Senator.all
  end

  # GET /senators/1
  # GET /senators/1.json
  def admin_show
    @senator = Senator.find(params[:id])
  end
  # GET /senators/new
  def new
    @senator = Senator.new
  end

  # GET /senators/1/edit
  def edit
  end

  def votes
    @senator = Senator.find(params[:id])
  end
  def admin_votes
    @senator = Senator.find(params[:id])
  end
  def donations
    @senator = Senator.find(params[:id])
  end
  def admin_donations
    @senator = Senator.find(params[:id])
    @donation = Donation.new
  end
  def contact
    @senator = Senator.find(params[:id])
  end
  # POST /senators
  # POST /senators.json
  def create
    @senator = Senator.new(senator_params)

    respond_to do |format|
      if @senator.save
        format.html { redirect_to @senator, notice: 'Senator was successfully created.' }
        format.json { render :show, status: :created, location: @senator }
      else
        format.html { render :new }
        format.json { render json: @senator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /senators/1
  # PATCH/PUT /senators/1.json
  def update
    respond_to do |format|
      if @senator.update(senator_params)
        format.html { redirect_to @senator, notice: 'Senator was successfully updated.' }
        format.json { render :show, status: :ok, location: @senator }
      else
        format.html { render :edit }
        format.json { render json: @senator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /senators/1
  # DELETE /senators/1.json
  def destroy
    @senator.destroy
    respond_to do |format|
      format.html { redirect_to senators_url, notice: 'Senator was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_senator
    @senator = Senator.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def senator_params
    params.require(:senator).permit(:name, :email, :party, :beliefs, :rating, :img, :district, :url)
  end
  def authenticate
    authenticate_or_request_with_http_digest do |username|
      USERS[username]
    end
  end
end
