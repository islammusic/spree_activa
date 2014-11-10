class Spree::ActivaController < Spree::CheckoutController

  prepend_before_filter :process_order, only: [:done, :fail]

  def process_order
    order = nil
    if request.get?
      order = Spree::Order.find(session[:aoid]) if session[:aoid]
      if order && order.complete?
        flash.notice = Spree.t(:order_processed_successfully)
        redirect_to order_url(order, :token => order.guest_token)
      else
        flash[:error] = I18n.t(:activa_payment_failed)
        if order
          redirect_to checkout_state_url(order.state)
        else
          redirect_to checkout_url
        end
      end
    else
      Spree::PaymentMethod.find(params[:udf2]).commit_payment(params) if params[:udf2]
      render text: ''
    end
    false
  end

  def init
    session[:aoid] = @order.id
    payment_method = Spree::PaymentMethod.find(params[:id])
    redirect_to payment_method.init_url(@order,activa_done_url, activa_fail_url)
  end


  def done
  end

  def fail
  end
end