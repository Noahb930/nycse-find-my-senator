require 'nokogiri'
require 'open-uri'
class SenatorsController < ApplicationController
  before_action :set_senator, only: [:show, :edit, :update, :destroy]

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

  # GET /senators
  # GET /senators.json
  def index
    @senators = Senator.all
  end

  # GET /senators/1
  # GET /senators/1.json
  def show
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
end
