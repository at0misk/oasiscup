class PaymentsController < ApplicationController
require 'digest/md5'
  # layout 'authorize_net'
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  # GET
  # Displays a payment form.
  def payment
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new('9CPC3p3r8J', '85GL7ApYu8v533sU', @amount, :relay_url => "http://www.oasiscup.com/payments/relay_response")
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
      sim_response = AuthorizeNet::SIM::Response.new(params)
      @amount = params[:x_amount].to_i
      @user = User.find(session[:user_id])
      @team = @user.team
      @transamount = params[:x_amount].to_f/100
      @cart = Cart.where(user_id: @user.id)
      if params[:x_MD5_Hash] == Digest::MD5.hexdigest('ABRACADABRA9CPC3p3r8J' + params[:x_trans_id] + params[:x_amount]).upcase && params[:x_response_code] == '1'
      # if sim_response.success?('9CPC3p3r8J', 'ABRACADABRA')
      # if params[:x_response_code] == '1'
        render :text => sim_response.direct_post_reply(payments_receipt_url(:only_path => false), :include => true)
      else
        @trans_id = params[:x_trans_id]
        @amount = params[:x_amount]
        @hash = params[:x_MD5_Hash]
        @response_code = params[:x_response_code]
        @reason = params[:x_response_reason_code]
        if @response_code == 1
          @response_code = "num"
        else
          @response_code = "string"
        end
        render :layout => false
      end
  end
  
  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

end