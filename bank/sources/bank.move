module bank::bank {

    use std::string::{Self, String}; //String Package for Self and String - String defs
    use sui::object::{Self, UID, ID}; //Object package for Self an UID for SUI Unique ID
    use sui::tx_context::{Self, TxContext}; //Self obj and TxContext obj
    use sui::coin::{Self, Coin};
    use sui::transfer; //Transfer mod for transfers txs
    use sui::event; //For Handling Events for NFT contract interaction



    //Asset Bank for NFT TX Data
    //Add Copy Trait to clone 
    //Drop Trait = drop to end lifetime at the EOO
    //Copy Trait = copy on OO
    //Key for Sui Global Storage Operations

//UID - id structure with type address and key trait
//ID - General ID
    struct AssetBank has key {
        id: UID, //UID for AssetBank Unique 
        number_of_deposits: u64, //For tracking number of deposits to the bank
        number_of_current_nfts: u64 //For current of nft deposited in

    }


    // ******** Asset Store Events ************/
    //Deposit event - Needs Drop Trait
    struct DepositEvent has drop, copy {
        asset_bank_id: UID, //Asset bank ID 
        deposit_amount: u64, //Deposit amount 
        address_of_depositor: address //Address of the depositor
    }

    //Withdrawal event - Needs Drop Trait
    struct WithdrawEvent has drop, copy {
        asset_bank_id: UID, //Asset Bank Struct ID 
        withdrawal_address: address, //Address of the recipient
        amount: u64, //Withdrawal Amount

    }

    //NFT Receipt Object - T is the type of token deposited
    //traits: key for onchain ID and store for global storage
    //Note to self: Removed drop trait it destroyed on withdrawal
    struct Receipt<T> has key, store {
        id: UID, //Unique ID for NFT's the users receive
        nft_count_value: u64, //NFT Count Prop
        address_of_depositor: address, //Address of the depositor (user)
        transaction_amount: u64, //Tokens Deposited Amount
    }



    //Deposit Method creates an NFT receipt and Transfer to caller
    //&mut just like rust -> mutable reference to assetbank for updating the state
    //Coin<T> - Sui Coin generic type for any coin type (SUI, USDC and USDT)
    //mutable reference to TxContext Obj (just like rust)
    //Make function an entry function to initialize entry point for tx
    public entry fun deposit<T>(bank: &mut AssetBank, coin: Coin<T>, ctx: &mut TxContext){

        //1. Revert Balance is balence provider for the coin object is zero     
        assert!(coin.value() > 0, "You cannot deposit with zero balance");

        //2. Take User Coin and deposit it into the Bank Object (Asset Bank Storage)
        //Switch take -> put (split issue on takee)
        coin::put(&mut bank.id, coin);//Consume coin (spending coin amount for NFT purchase) 

        //3. Handle Asset Bank Internal State// - State first
        bank.number_of_deposits = bank.number_of_deposits + 1; //Deposit State - Increase the num of deposits
        bank.number_of_current_nfts = bank.number_of_current_nfts + 1;//Active NFTs State - Increase the number of active NFTs


        //4. NFT Transaction receipt for user
        let unique_nft_id = object::new(ctx); //Pass mutable txContext ref to Generate unique nft id
        let nft_receipt = Receipt {
            id: unique_nft_id, //NFT ID
            nft_count_value: bank.number_of_deposits, //State var of count
            address_of_depositor: tx_context::sender(ctx), //similar to msg.sender via ctx object
            transaction_amount: coin.value() //Pass copy of the coin.value aka amount
        }; 

        
        //5. Transfer NFT to caller (our user)
        transfer::transfer(nft_receipt, tx_context::sender(ctx));//Note Self check move scopes


        //6. Emit an appropraite deposit event
        event::emit(DepositEvent {
            asset_bank_id: bank.id, //Asset Bank ID
            deposit_amount: coin.value(), //Deposit Amount
            address_of_depositor: tx_context::sender(ctx)
        });



    }

    //Expose public method to withdraw funds by returning minted NFT
    public entry fun withdraw<T>(bank: &mut AssetBank, receipt: Receipt<T>){

        //1. Remove the balance equal to receipt.amount() from asset bank of the coin type
        let amount = receipt.amount; //payment amount
        let address_of_depositor = receipt.address_of_depositor; //depositor address on chain

        //Note to self: coin params - mutable ref of Coin (1st), amount to take (2nd)
        let coin = coin::take<T>(&mut bank.id, amount);//Covert the balance into a coin

        //2. Transfer coin to receipt.depositor (nft depositor)
        transfer::transfer(coin, address_of_depositor);

        //3. Handle NFT count state of the Asset Bank (decrement by 1)
        bank.number_of_current_nfts = bank.number_of_current_nfts - 1;

        //4. Destroy the receipt (NFT receipt object)
        object::delete(receipt);

        //5. Emit an appropriate withdrawal event
        //Note to self - Withdraw needs the copy trait (event types) (run testing)
        event::emit(WithdrawEvent {
            asset_bank_id: bank.id,
            withdrawal_address: address_of_depositor,
            amount: amount
        });
    }

}
