class Spree::ActivaController < Spree::CheckoutController

  prepend_before_filter :process_order, only: :done

  def process_order
    return true if request.get?
    render nothing: true
    Spree::PaymentMethod.find(params[:udf2]).commit_payment(params) if params[:udf2]
    false
  end

  def init
    payment_method = Spree::PaymentMethod.find(params[:id])
    redirect_to payment_method.init_url(@order,activa_done_url, activa_fail_url)
  end


  def done
    redirect_to checkout_state_url(:complete)
  end

  def fail
    flash[:error] = I18n.t(:activa_payment_failed)
    redirect_to checkout_state_url(:payment)
  end
end