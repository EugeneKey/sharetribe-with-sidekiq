module PaypalService::API::Worker

  ProcessTokenStore = PaypalService::Store::ProcessToken

  module_function

  def enqueue_payments_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = ProcessTokenStore.create(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input)

    if proc_token
      schedule_payments_job(proc_token)
      proc_token
    else
      ProcessTokenStore.get_by_transaction(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name)
    end
  end

  def enqueue_billing_agreements_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = ProcessTokenStore.create(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input)

    if proc_token
      schedule_billing_agreements_job(proc_token)
      proc_token
    else
      ProcessTokenStore.get_by_transaction(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name)
    end
  end


  # Privates

  def schedule_payments_job(proc_token)
    PaypalService::Jobs::ProcessPaymentsCommand.perform_later(proc_token[:process_token])
  end

  def schedule_billing_agreements_job(proc_token)
    PaypalService::Jobs::ProcessBillingAgreementsCommand.perform_later(proc_token[:process_token])
  end

end
