require "nokogiri"

class Spree::Gateway::Activa < Spree::Gateway
  preference :id, :string
  preference :password, :string
  preference :langid, :string, :default => 'SLO'
  validates :preferred_langid, :inclusion=> { :in => %w(SLO USA SRB ITA FRA DEU ESP),:message => "Allowed locales: SLO USA SRB ITA FRA DEU ESP" }

  def provider_class
    ActiveMerchant::Billing::ActivaGateway
  end

  def source_required?
    false
  end

  def auto_capture?
    false
  end

  # Spree usually grabs these from a Credit Card object but when using
  # Adyen Hosted Payment Pages where we wouldn't keep # the credit card object
  # as that entered outside of the store forms
  def actions
    %w{capture void}
  end

  # Indicates whether its possible to void the payment.
  def can_void?(payment)
    !payment.void?
  end

  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    payment.pending? || payment.checkout?
  end

  def method_type
    'activa'
  end

  def init_url(order,activa_done_url, activa_fail_url)
    # activa_done_url = 'http://1943d9e2.ngrok.com/activa/done'
    # activa_fail_url = 'http://1943d9e2.ngrok.com/activa/fail'
    am = provider_class.new(login: preferred_id, password: preferred_password)
    am.purchase(order.total,{},{currency: order.currency.to_s, langid: preferred_langid, responseURL: activa_done_url+"?udf2=#{self.id}", errorURL: activa_fail_url, trackid: order.number, udf1: secret_hash(order.number), udf2: self.id})
  end


  def commit_payment(params)
    order = Spree::Order.incomplete.includes(:adjustments).lock(:lock => true).find_by(number: params[:trackid])
    return if secret_hash(order.number) != params[:udf1]
    return unless ["CAPTURED", "APPROVED"].include? params[:result]
      ActiveRecord::Base.transaction do
        payment = order.payments.where(:payment_method_id => self.id).first

        unless payment
          payment = order.payments.create(:amount => order.total,:payment_method => self, state: 'completed', response_code: params[:ref])
          order.payment_total += payment.amount
        end

        unless order.completed?
          until order.state == "complete"
            if order.next!
              order.update!
            end
          end

          order.finalize!
        end

    end
  end

  def secret_hash(value)
    Digest::MD5.hexdigest(preferred_password+value)
  end

end


