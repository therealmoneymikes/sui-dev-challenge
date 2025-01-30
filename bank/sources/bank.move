module bank::bank {


    use sui::coin::{Self, Coin};
    use sui::transfer; //Transfer mod for transfers txs
    use sui::event; //For Handling Events for NFT contract interaction
    use bank::errors;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::bag::{Self, Bag};
    use sui::dynamic_field;
    
    
    // use sui::balance::{Self, Balance}

    //Asset Bank for NFT TX Data
    //Add Copy Trait to clone, Drop Trait = drop to end lifetime at the EOO, Copy Trait = copy on OO, Key for Sui Global Storage Operations

    //UID - id structure with type address and key traitID - General ID, Note to self: drop and copy conflicts with key
    public struct AssetBank has key {
        id: UID, //UID for AssetBank Unique 
        number_of_deposits: u64, //For tracking number of deposits to the bank
        number_of_current_nfts: u64, //For current of nft deposited in
        admin: address, //Admin of the Asset Bank Obkect
        balances: Bag, //Map object like ts for storing user balances  
        receipts: Bag, //Store all the deposit receipts
    }
    


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

    //NFT Receipt Object - T is the type of token deposited
    //Claim state to avoid double spending
    public struct Receipt<phantom T> has key, store {
        id: UID, //Unique ID for NFT's the users receive
        number_of_active_nfts: u64, //NFT Count Prop
        number_of_deposits: u64, //Number of deposit in the Asset Bank
        address_of_depositor: address, //Address of the depositor (user)
        amount: u64, //Tokens Deposited Amount
        claimed: bool, //Claim State (set to true on creation)
    }

    //Contract Initation Function (Init)
    public fun init(ctx: &mut TxContext): AssetBank {
        //Create a new asset bank
        //Note to self: new returns ctx.fresh_object_address() as bytes prop for UID
        let asset_bank = AssetBank {
            id: object::new(ctx), //Assign UID to register on Sui
            owner: tx_context::sender(ctx), //Contract Initialiser -> Admin 
            number_of_deposits: 0,//Initial Deposit State is 0 on deployment
            number_of_current_nfts: 0,//Initial NFT Count state is 0 on deployment
            balances: bag::new(ctx),//Initialize a new store table object to keep track of user balances
            receipts: bag::new(ctx),//Initialize a new store table object to keep track of receipts
        };

        //Share the AssetBank Object with user to call the methods deposit and withdraw
        transfer::share_object(asset_bank);
        asset_bank
    }


    //Deposit Method creates an NFT receipt and Transfer to caller
    //&mut just like rust -> mutable reference to assetbank for updating the state
    //Coin<T> - Sui Coin generic type for any coin type (SUI, USDC and USDT)
    //mutable reference to TxContext Obj (just like rust)
    public entry fun deposit<T>(bank: &mut AssetBank, coin: Coin<T>, ctx: &mut TxContext){
        let deposit_amount = coin::value(&coin); //get coin by ref and pass it to value method - Returns amount
        //1. Revert Balance is balence provider for the coin object is zero     
        assert!(deposit_amount > 0, 0);

        //2. Update Asset Bank by key-value pair dynamic field instead of balance only 
        //PART A - If Statement checks if depositor address and balance does exist before creating a new entry
        if(!dynamic_field::exists_<T, Balance<T>>(&bank.balances)){
            let balance = balance::zero<T>(); //sets balance key to 0 first
            //Note to self - Add has 3 args - &mut object, name, coin value (Value)
            dynamic_field::add(&mut bank.balances, T, balance); //Add  
        };

        //PART B - Add new user balance to the asset coin amount
        //Taking a mutable reference to the bag table balances dynamic field to add to asset bank tables
        //Returns a mutable reference field Value
        let balance = dynamic_field::borrow_mut<T, Balance<T>>(&mut bank.balances);
        balance::join(balance, coin::into_balance(coin)); //Join users coin amount of type T to balance value field

        //3. Handle Asset Bank Internal State
        //Fix: Pass receipt_number instead of incrementation logic
        
        //PART A - Generate NFT Receipt Object
        receipt_number = bank.number_of_deposits + 1; //Deposit State - Increase the num of deposits
        //4. NFT Transaction receipt for user and send it
        let receipt_id = object::new(ctx); //Pass mutable txContext ref to Generate unique nft id
        let nft_receipt = Receipt<T> {
            id: receipt_id, //NFT Receipt ID
            nft_count_value: receipt_number, //State var of count
            address_of_depositor: tx_context::sender(ctx), //similar to msg.sender via ctx object
            amount: deposit_amount, //Add deposit amount from var
            claimed: true //Set claimed state to true when user generates an NFT
        }; 

        //Transfter NFT receipt with claimed prop set to true
        transfer::transfer(nft_receipt, tx_context::sender(ctx));

        //PARTB - Update Asset State before emitting the event
        bank.deposit_count = receipt_number; //Deposit Count State (u64 val)
        bank.number_of_active_nfts = bank.active_nfts + 1; //Increment Active NFTs by one;

        //4. Emit an appropraite deposit event
        //Carry T type
        event::emit(DepositEvent<T> {
            nft_receipt_number: receipt_number, //Assign NFT receipt number to Deposit Event
            deposit_amount, //Deposit Amount - here deposit_amount:deposit_amount evalautes to deposit_amount (like JS/TS)
            address_of_depositor: tx_context::sender(ctx)
        });



    }

    //Expose public method to withdraw funds by returning minted NFT
    public entry fun withdraw<T>(bank: &mut AssetBank, receipt: Receipt<T>){

        //1. Remove the balance equal to receipt.amount() from asset bank of the coin type
        let amount = receipt.amount; //payment amount
        let address_of_depositor = receipt.address_of_depositor; //depositor address on chain

        //Note to self: coin params - mutable ref of Coin (1st), amount to take (2nd)
        let coin = coin::take<T>(&mut bank.id, amount);//Convert the balance into a coin

        //2. Transfer coin to receipt.depositor (nft depositor)
        transfer::transfer(coin, address_of_depositor);

        //3. Handle NFT count state of the Asset Bank (decrement by 1)
        bank.number_of_current_nfts = bank.number_of_current_nfts - 1;

        //4. Destroy the receipt (NFT receipt object)
        object::delete(receipt);

        //5. Emit an appropriate withdrawal event
        //Note to self - Withdraw needs the copy trait (event types) (run testing)
        event::emit(WithdrawEvent {
        id: object::new(ctx),
        withdrawal_address: address_of_depositor,
        amount: amount
        });
    }

}
