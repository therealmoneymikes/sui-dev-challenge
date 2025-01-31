module bank::events {
    use sui::event;


    // ******** Asset Store Events ************/
    //Deposit event 
    public struct DepositEvent has copy, drop  {
        nft_receipt_number: u64,
        deposit_amount: u64, //Deposit amount 
        address_of_depositor: address //Address of the depositor
    }

    //Withdrawal event
    public struct WithdrawEvent has copy, drop {
        nft_receipt_number: u64,
        amount: u64, //Withdrawal Amount
        address_of_depositor: address, //Address of the recipient (Person who deposited)

    }
}