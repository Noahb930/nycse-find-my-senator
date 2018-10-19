class BillsController < ApplicationController
  USERS = { ENV['USERNAME'] => ENV['PASSWORD'] }
  before_action :set_bill, only: [:show, :edit, :update, :destroy]
  before_action :authenticate
  # GET /bills
  # GET /bills.json
  def index
    @bills = Bill.all
  end
  def admin_index
    @bills = Bill.all
  end
  # GET /bills/1
  # GET /bills/1.json
  def admin_show
    @bill = Bill.find(params[:id])
  end

  # GET /bills/new
  def new
    @bill = Bill.new
  end

  # GET /bills/1/edit
  def edit
    @bill = Bill.find(params[:id])
  end

  # POST /bills
  # POST /bills.json
  def create
    @bill = Bill.new(bill_params)

    respond_to do |format|
      if @bill.save
        Representative.all.each do |representative|
          puts "representative"
            vote = Vote.new(bill_id:@bill.id, representative_id:representative.id, stance:"unknown")
            vote.save();
            @bill.votes.push(vote)
            @bill.save()
            representative.votes.push(vote)
            representative.save()
        end
        format.html { redirect_to @bill, notice: 'Bill was successfully created.' }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { render :new }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bills/1
  # PATCH/PUT /bills/1.json
  def update
    respond_to do |format|
      if @bill.update(bill_params)
        format.html { redirect_to @bill, notice: 'Bill was successfully updated.' }
        format.json { render :show, status: :ok, location: @bill }
      else
        format.html { render :edit }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    @bill.votes.each do |vote|
      vote.destroy
    end
    @bill.destroy
    respond_to do |format|
      format.html { redirect_to bills_url, notice: 'Bill was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill
      @bill = Bill.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bill_params
      params.require(:bill).permit(:number, :status, :session, :summary, :shorthand, :supports_gun_control , :url)
    end

    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
