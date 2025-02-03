// module bank::bank {


//     use sui::coin::{Self, Coin};
//     use sui::transfer; //Transfer mod for transfers txs
//     use sui::event; //For Handling Events for NFT contract interaction
//     use bank::errors;
//     use sui::tx_context::TxContext;
//     use sui::object::{Self, UID};
//     use sui::balance::{Self, Balance};
//     use sui::bag::{Self, Bag};
//     use sui::dynamic_field;
    
    
//     // use sui::balance::{Self, Balance}

//     //Asset Bank for NFT TX Data
//     //Add Copy Trait to clone, Drop Trait = drop to end lifetime at the EOO, Copy Trait = copy on OO, Key for Sui Global Storage Operations

//     //UID - id structure with type address and key traitID - General ID, Note to self: drop and copy conflicts with key
//     public struct AssetBank has key, store {
//         id: UID, //UID for AssetBank Unique 
//         number_of_deposits: u64, //For tracking number of deposits to the bank
//         number_of_current_nfts: u64, //For current of nft deposited in
//         admin: address, //Admin of the Asset Bank Obkect
//         balances: Bag, //Map object like ts for storing user balances  
//         receipts: Bag, //Store all the deposit receipts
//     }
    


//     // ******** Asset Store Events ************/
//     //Deposit event 
//     public struct DepositEvent has copy, drop  {
//         nft_receipt_number: u64,
//         deposit_amount: u64, //Deposit amount 
//         address_of_depositor: address //Address of the depositor
//     }

//     //Withdrawal event
//     public struct WithdrawEvent has copy, drop {
//         nft_receipt_number: u64,
//         amount: u64, //Withdrawal Amount
//         address_of_depositor: address, //Address of the recipient (Person who deposited)

//     }

//     //NFT Receipt Object - T is the type of token deposited
//     //Claim state to avoid double spending
//     public struct Receipt<T> has key, store {
//         id: UID, //Unique ID for NFT's the users receive
//         nft_receipt_number: u64,
//         address_of_depositor: address, //Address of the depositor (user)
//         amount: u64, //Tokens Deposited Amount
//         claimed: bool, //Claim State (set to true on creation)
//     }

//     //Contract Initation Function (Init)
//     fun init(ctx: &mut TxContext) {
//         //Create a new asset bank
//         //Note to self: new returns ctx.fresh_object_address() as bytes prop for UIDid: UID, //UID for AssetBank Unique 

//         let asset_bank = AssetBank {
//             id: object::new(ctx), //Assign UID to register on Sui
//             number_of_deposits: 0,//Initial Deposit State is 0 on deployment
//             number_of_current_nfts: 0,//Initial NFT Count state is 0 on deployment
//             admin: tx_context::sender(ctx), //Contract Initialiser -> Admin 
//             balances: bag::new(ctx),//Initialize a new store table object to keep track of user balances
//             receipts: bag::new(ctx),//Initialize a new store table object to keep track of receipts
//         };

//         //Share the AssetBank Object with user to call the methods deposit and withdraw
//         transfer::share_object(asset_bank);
//         asset_bank
//     }


//     //Deposit Method creates an NFT receipt and Transfer to caller
//     //&mut just like rust -> mutable reference to assetbank for updating the state
//     //Coin<T> - Sui Coin generic type for any coin type (SUI, USDC and USDT)
//     //mutable reference to TxContext Obj (just like rust)
//     public entry fun deposit<T: copy>(bank: &mut AssetBank, coin: Coin<T>, ctx: &mut TxContext){

//         let deposit_amount = coin::value(&coin); //get coin by ref and pass it to value method - Returns amount
//         //1. Revert Balance is balence provider for the coin object is zero     
//         assert!(deposit_amount > 0, 0);

//         //2. Update Asset Bank by key-value pair dynamic field instead of balance only 
//         //PART A - If Statement checks if depositor address and balance does not exist before creating a new entry
//         if(!dynamic_field::exists_<T>(&bank.id)){
//             let balance = balance::zero<T>(); //sets balance key to 0 first
//             //Note to self - Add has 3 args - &mut object, name, coin value (Value)
//             dynamic_field::add(&mut bank.balances, T, balance); //Adds a new nft count and receipt object to the bag
//         };

//         //PART B - Add new user balance to the asset coin amount
//         //Taking a mutable reference to the bag table balances dynamic field to add to asset bank tables
//         //Returns a mutable reference field Value
//         let balance = dynamic_field::borrow_mut<Balance<T>>(&mut bank.id, T);
//         balance::join(balance, coin::into_balance(coin)); //Join users coin amount of type T to balance value field

//         //3. Generate NFT Transaction receipt for user and send it
//         //Deposit State - Increase the num of deposits
//         let receipt_number = bank.number_of_deposits + 1; 
//         let receipt_id = object::new(ctx); //Pass mutable txContext ref to Generate unique nft id
//         let nft_receipt = Receipt<T> {
//             id: receipt_id, //NFT Receipt ID
//             nft_receipt_number: receipt_number, //State var of count -
//             address_of_depositor: tx_context::sender(ctx), //similar to msg.sender via ctx object
//             amount: deposit_amount, //Add deposit amount from var
//             claimed: false //Set claimed state to false when user generates an NFT
//         }; 

//         //Store the nft receipt in the bank bag 
//         //args (UID, name (key), value)
//         dynamic_field::add(&mut bank.id, receipt_number, receipt);

//         //Transfter NFT receipt with claimed prop set to true
//         transfer::transfer(nft_receipt, tx_context::sender(ctx));

//         //PARTB - Update Asset State before emitting the event
//         bank.deposit_count = receipt_number; //Deposit Count State (u64 val)
//         bank.number_of_active_nfts = bank.active_nfts + 1; //Increment Active NFTs by one;

//         //4. Emit an appropraite deposit event
//         //Carry T type
//         event::emit(DepositEvent<T> {
//             nft_receipt_number: receipt_number, //Assign NFT receipt number to Deposit Event
//             deposit_amount, //Deposit Amount - here deposit_amount:deposit_amount evalautes to deposit_amount (like JS/TS)
//             address_of_depositor: tx_context::sender(ctx)
//         });



//     }

//     //Expose public method to withdraw funds by returning minted NFT
//     public fun withdraw<T>(bank: &mut AssetBank, receipt: Receipt<T>, ctx: &TxContext){
//         //UPDATE - On reviewing the caller of the function needs to verified before state management
//         //NOTE the sui::object module doesn't contain a direct way to find the call of the function
//         //So I've added a third param ctx to get the transaction context object to get the caller
        
//         //1. Get Contract caller and receipt info
//         //Here I am grabbing the contract call to assert if caller of withdraw has a deposit in the AssetBank
//         let address_of_depositor = tx_context::sender(ctx);
//         //user_entry = cross checks for nft_receipt number of nft receipt holder with asset bank nft record in the bag
//         let user = dynamic_field::exists_<u64>(&receipt.id, receipt.nft_receipt_number);
//         assert!(user, bank::errors::ge_unauthorised_user_acccess()); //Error raised if contract caller is not the depositor address

//         //2. Check if contract caller's address matches the address_of_depositor
//         assert!(receipt.address_of_depositor == address_of_depositor, 1010);

//         //3. Check if the NFT receipt is claimed by a user already
//         assert!(!receipt.claimed, 1011); 

//         //3b. Since we need to provide the balance the user deposit 
//         //   I'm checking the Asset Bank Balance Bag (key-value object)
//         let asset_bank_balance = dynamic_field::exists_<T>(&mut bank.id);
//         //Raises assert exception if balance is not sufficient
//         assert!(!asset_bank_balance, 1012);
//         //Extract the balance as mut reference
//         let balance = dynamic_field::borrow_mut<T, Balance<T>>(&mut bank.id, T); //Returns (id and value)
//         //Raises assert exception if balance in asset bank is not enough for the receipt.amount
//         assert!(balance::value(balance) >= receipt.amount, 1013);
    
//         //If the asset bank has enough balance ( which is should :)...abort
//         //Then we can extract the balance and covert it to a transferable coin
//         let coin = sui::coin::from_balance(balance::split(balance, receipt.amount), ctx);
//         //Then transfer the coin from the balance to the function call (depositor)
//         transfer::transfer(coin, address_of_depositor);


      
//         //To handle to the prevention of a reentrancy attack (double spend)
//         //mut by value for receipt
//         let mut mut_receipt = receipt;
//         //Access the claimed prop and change the actual value not the ref value (copied)
//         mut_receipt.claimed = true; // Mark nft receipt as used now
//         //Here I've replaced by value the receipt object with key receipt number for the old entry
//         dynamic_field::add(&mut bank.id, receipt.nft_receipt_number, mut_receipt);


//         //4. Update the state of current nfts
//         //Here I'm not do anything to the state of receipts count only active nfts 
//         //nfts count be balanced asset bank other wise we go broke :)
//         bank.number_of_current_nfts = bank.number_of_current_nfts - 1;

//         //5. Destroy the receipt (NFT receipt object)
//         object::delete(receipt.id);

//         //6. Emit an appropriate withdrawal event
//         //Note to self - Withdraw needs the copy trait (event types) (run testing)
//         event::emit(WithdrawEvent {
//         nft_receipt_number: receipt.nft_receipt_number, //NFT Receipt number that is consumed
//         amount: receipt.amount,//Amount transfer to the rightful user (depositor)
//         address_of_depositor: address_of_depositor, //Address of depositor
//         });

//     }

// }
