class PaymentsController < ApplicationController

  # layout 'authorize_net'
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  # GET
  # Displays a payment form.
  def payment
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new('9CPC3p3r8J', '85GL7ApYu8v533sU', @amount, :relay_url => 'http://developer.authorize.net/bin/developer/paramdump')
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
      puts("Processing..")
      print("whatat")
      sim_response = AuthorizeNet::SIM::Response.new(params)
      if sim_response.success?('9CPC3p3r8J', 'PBDGMKX')
        render :text => sim_response.direct_post_reply(payments_receipt_url(:only_path => false), :include => true)
      else
        render
      end
  end
  
  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

end