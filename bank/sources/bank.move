//https://yakitori.dev/blog/00-sui-move-for-solidity-devs/#object-ownership

//**************** Important NOTE - SINCE &Balance cannot be directly Balance it cannot be stored on the Receipt<T> object because according Sui it is to prevent security issues
//*****                             Therefore all the logic is based on u64 values rather than Balance<T>  each code where errors occur in in note.txt ******/
#[allow(unused_const)] //The allow(ununsed_count) is to suppress errors with error const values (some are for testing only)
module bank::bank; 

    
    //standard libs - MoveStdLbs
    use std::type_name::{Self, TypeName};
    use std::string::String;
   
    
    //standard sui libs
 
    use sui::event; //For Handling Events for NFT contract interaction
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object_table::{Self, ObjectTable};

   

    //Custom Error Codes
     const GE_ZERO_DEPOSIT_COUNT: u64 = 1000; //Error Condition when number_of_deposit is NOT zero
     const GE_ZERO_NFTS_COUNT: u64 = 1001; //Errr Condition when number_of_current_nfts is NOT zero
     const GE_INVALID_ASSET_BANK_STATE: u64 = 1002; //Error Condition for incorrect or invalid bank state
     const GE_TREASURY_IS_NOT_INITIALISED: u64 = 1003; //Error Condition where treasury is not initialised i.e count = 1
     const GE_TREASURY_IS_ALREADY_INITIALISED: u64 = 1004; //Error Condition where treasury is initialised i.e count = 1
     
     const GE_TREASURY_MAX_LIMIT: u64 = 1005; //Error Condition where treasury is at the max allowed exists = 1
    /* User Smart Contract Interactions  (Asset Bank Transaction)*/
    const GE_ZERO_USER_INSUFFICIENT_FUNDS: u64 = 1006; //Error Condition when user has insufficient coin funds
    const GE_UNAUTHORISED_USER_ACCESS: u64 = 1007; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    const GE_USER_HAS_NO_FUNDS_IN_TREASURY: u64 = 1008; //Error Condition if no funds for user of address is in the treasury
    const GE_USER_NFT_IS_INVALID: u64 = 1009;

    /* Testing Environment Smart Contract Inteactions - All Test Codes start with 2000*/
     const TE_ASSET_BANK_COUNT_IS_NOT_ONE: u64 = 2000; 
     const TE_ASSET_NFT_COUNT_IS_NOT_ONE: u64 = 2001;
     const TE_INVALID_ASSET_BANK_STATE: u64 = 2003; //Error Condition for incorrect or invalid bank state
     const TE_TREASURY_IS_NOT_INITIALISED: u64 = 2004; //Error Condition where treasury is not initialised i.e count = 1
     const TE_TREASURY_IS_ALREADY_INITIALISED: u64 = 2005; //Error Condition where treasury is initialised i.e count = 1
     const TE_TREASURY_MAX_LIMIT: u64 = 2006; //Error Condition where treasury is at the max allowed exists = 1


    //NOTE - It's important to note that Move objects have a maximum size of 250KB
    





    //AssetBank Object
    //key for UID + storage for allow other objs and making it transferable
    public struct AssetBank has key, store {
        id: UID, //UID for AssetBank Unique 
        number_of_deposits: u64, //For tracking number of deposits to the bank
        number_of_active_nfts: u64, //For current of nft deposited in
        admin: address, //Admin of the Asset Bank Object
        is_treasury_initialised: bool, //Boolean Flag to check if treasure has been initialised - will be false on init
        treasury_count: u64, //Start as 0 and can only every be 1 after Asset Bank Init
        total_treasury_balance: u64//Total Coins amounts as u64
    }
    // Asset Bank Initialisation Event Struct 
    public struct AssetBankInitEvent has store, copy, drop {
        asset_bank_id: ID,
        creator: address,
        deposit_count: u64,
        nft_count: u64,
        total_treasury_balance: u64
    }
      //Event Emitters for Assetbank//
    public fun asset_bank_init_event(ctx: &mut TxContext, bank_uid: &UID, number_of_deposits: &u64, number_of_current_nfts: &u64, total_treasury_balance: &u64) {
        let sender = ctx.sender();
        let inner_bank_id = bank_uid.uid_to_inner(); //UID -> ID
        let number_of_deposits_dr = *number_of_deposits;
        event::emit(AssetBankInitEvent {asset_bank_id: inner_bank_id, creator: sender, deposit_count: number_of_deposits_dr, nft_count: *number_of_current_nfts, total_treasury_balance: *total_treasury_balance });
    }  

   

    //*** Public View Functions Interfaces for On-Chain Asset Bank Info  **/
    public fun get_treasury_count(bank: &AssetBank): &u64 {
        &bank.treasury_count
    }
    //Returns number of deposits
    public fun get_deposits(bank: &AssetBank): &u64 {
        &bank.number_of_deposits
    }
    //Retuns number of active nfts
    public fun get_number_of_active_nfts(bank: &AssetBank): &u64 {
        &bank.number_of_active_nfts
    }
    //Returns Admin of the asset bank (which also the admin of the treasury)
    public fun get_admin(bank: &AssetBank): &address {
        &bank.admin
    }

    public fun treasury_count(bank: &AssetBank): &u64 {
        &bank.treasury_count
    }
    

    //**** ONE TIME WITNESSES **/
    public struct BANK has drop {}//Treasury Witness to ensure bank is only initiialised once
    public struct TREASURYWITNESS has drop {} //Treasury Witness to ensure the Treasury is created once only




    //****** TREASURY LOGIC - START **********/

    //T coin the store and copy - Struct to hold coin_type and amount as an object
    public struct CoinTypeStruct<phantom T> has key, store {
         id: UID,
         coin_type: String, //Vector of Bytes = String Type in the std as ascii's
         amount: u64,
         balance: Balance<T>
         
    }
    //CHANGEE: Since AssetBank is not of type T Treasury Object is needed here
    #[allow(missing_phantom)]
    public struct Treasury<T: store + key> has key, store {
        id: UID, //Unique Id of the treasury
        asset_bank_id: ID, //Asset Bank ID stored to declare Treasury -> Asset Bank Relationship
        vault: ObjectTable<address, CoinTypeStruct<T>>, //User balance table to store address and amounts
        //coin_vault: Balance<T>, //Coin type
    }
    //Init treasury function - Avoiding the error trying pass a generic type to constructor
    fun create_treasury<T: store + key>(_: TREASURYWITNESS, ctx: &mut TxContext, bank_uid: &UID): Treasury<T> {
        let inner_bank_id = bank_uid.uid_to_inner();
        let treasury = Treasury {id: object::new(ctx), asset_bank_id: inner_bank_id, vault: object_table::new(ctx)};
        treasury
    }

    ///Treasury Init Event Struct
      public struct TreasuryInitEvent has copy, drop {
        asset_bank_id: ID,
        treasury_id: ID,
        admin: address,
    }
    //Emit Treasury Init Event Function
    fun emit_treasury_init_event(bank_uid: &UID, treasury_uid: &UID){
        let inner_bank_id = bank_uid.uid_to_inner(); //&UID ref -> ID value
        let inner_treasury_id = treasury_uid.uid_to_inner(); //&UID ref -> ID value
        let treasury = TreasuryInitEvent {
            asset_bank_id: inner_bank_id,//Unique Event of the Treasuries Creation
            treasury_id: inner_treasury_id, //The uid of the treasury
            admin: bank_uid.uid_to_address() //Admin address
        };
        event::emit(treasury)
    }

     //*** Public View Functions Interfaces for On-Chain Treasury Info **/


      //****** TREASURY LOGIC - END **********/





    //****** DEPOSIT EVENT LOGIC - START **********/
    //Deposit Event - Traits copy: can be immutable refd, can be destroyed 
    public struct DepositEvent has copy, drop {
        object_id: ID,
        deposit_amount: u64, //Deposit amount 
        address_of_depositor: address //Address of the depositor
       
    }
    //Deposit event emit function
    fun emit_deposit_event(receipt_uid: &UID, deposit_amount: &u64, depositor_address: &address ) {
        let inner_bank_id = receipt_uid.uid_to_inner();
        event::emit(DepositEvent {object_id: inner_bank_id, deposit_amount: *deposit_amount, address_of_depositor: *depositor_address});
    }   
   //****** DEPOSIT EVENT LOGIC - END  **********/


 //****** WITHDRAWAL EVENT LOGIC - START **********/
     //Withdrawal event
    public struct WithdrawEvent has drop, copy {
        object_id: ID,
        withdraw_amount: u64, //Withdrawal Amount
        address_of_depositor: address, //Address of the recipient (Person who deposited)
    }
    //Withdrawl Event Emit Function
    public fun emit_withdraw_event(withdraw_amount: u64, ctx: &mut TxContext, bank: &AssetBank) {
        let sender = ctx.sender();
        let inner_bank_id = bank.id.uid_to_inner();
        event::emit(WithdrawEvent {object_id: inner_bank_id, withdraw_amount, address_of_depositor: sender})
    }
 //****** WITHDRAWAL EVENT LOGIC - END **********/

//****** RECEIPT NFT EVENT LOGIC - TART **********/
    //NFT Receipt Object
    //Lint mute on coin_field to supress Coin<T> Linting Suggestion
    #[allow(lint(coin_field))] 
    public struct Receipt<phantom T> has key, store {
        id: UID, //GElobal SUI ID 
        nft_count: u64, //NFT count value
        address_of_depositor: address, //Address of the Coin Depositor
        coin_balance: u64,//Amount of tokens deposited of Type T - SUI, USDT, USDC
        coin_type: TypeName, //utf8 string 
        is_locked: bool //Holds teh state of Receipt (Defaults to true on mint event)
    }

 //NFT Receipt minting function
 //This flag is 
//  #[allow(lint(self_transfer))]
//   fun mint_nft<T: store + key + drop>(bank: &mut AssetBank, ctx: &mut TxContext, coin: Coin<T>) {
//         let sender = ctx.sender();
//         let new_nft = Receipt<T> {
//             id: object::new(ctx),//Unique ID of the NFT Receipt
//             nft_count: bank.number_of_active_nfts + 1,
//             address_of_depositor: sender,
//             coin_balance: coin,
//             is_locked: true
            
//         };
        
//         let amount = coin::value(&new_nft.coin_balance);
//         emit_deposit_event(&new_nft.id, &amount, &ctx.sender());
        
//         transfer::transfer(new_nft, ctx.sender())

//    }


//****** RECEIPT NFT EVENT LOGIC - END **********/




 //****** DEPOSIT FUNCTIONALITY - START **********/   
    //T value passed in must have the store, key and copy trait
    #[allow(lint(self_transfer))] 
    public fun deposit<T: store + key + copy>(bank: &mut AssetBank, coin: Coin<T>, treasury: &mut Treasury<T>, ctx: &mut TxContext) {

        //const SUI_TYPE_NAME: vector<u8> = b"0000000000000000000000000000000000000000000000000000000000000002::sui::SUI";
    //1. Check if the treasury is activated first
    assert!(bank.is_treasury_initialised == true, GE_TREASURY_IS_NOT_INITIALISED);
    //Do need to the count state because it will always be one

 
    //2. Revert if the balance of the provided coin object is ZERO 
    let coin_amount = coin.value(); //returns self.balance.value() - u64
    //If coin amount is zero we abort the process
    assert!(coin_amount > 0, GE_ZERO_USER_INSUFFICIENT_FUNDS);

    //Add a new entry for the users amount - K = Adresss, V is UserBalanceStructm where we store {amount and Coin<T>}
    let coin_type_as_string_ascii = type_name::get<T>().into_string(); //get the name of Coin Type of T (at Run type)
    let coin_from_ascii_to_utf8 = std::string::from_ascii(coin_type_as_string_ascii);
    //Note get<T> returns ascii::String
    //from_ascii to convert to UTF8 string

     //Consume the coin 
    //Read the X amount of balance from the Coin <T> and produce another Coin<T> to send to treasury
    //coin_amount -> total_coin_amount owns the data
    // let total_coin_amount_as_coin = coin.into_balance(); 
    // let total_coin_amount_as_u64 = total_coin_amount_as_coin.value();//Returns u64
    // vault: ObjectTable<address, CoinTypeStruct<T>>
    let amount = coin_amount;
    let amount_struct = CoinTypeStruct {id: object::new(ctx), coin_type: coin_from_ascii_to_utf8, amount, balance: coin.into_balance()};
    
    treasury.vault.add(ctx.sender(), amount_struct); //Add the new entry to Treasury Object then update the Asset Bank

    
    //3. Increase the number of deposits
    //4. Increase the number of active NFTs
    //5. Increase the total balance of the asset bank
    //Based on Hypothesis 1 the proxy relationship is here where as the Treasury increases in coin amounts
    //The Bank will be updated by count only to avoid directly storing coins here
    bank.number_of_deposits = bank.number_of_deposits + 1; //Update deposit count state
    bank.number_of_active_nfts = bank.number_of_active_nfts + 1; //Update active NFT state
    bank.total_treasury_balance = bank.total_treasury_balance + amount; //Update total balance

    //6. Generate NFT Receipt - Call Mint NFT function
    //  let get_coin_type = type_name::get<T>().into_string();
    // let get_coin_type_ascii_to_utf8 = std::string::from_ascii(get_coin_type);
    let new_nft = Receipt<T> {
            id: object::new(ctx),//Unique ID of the NFT Receipt
            nft_count: bank.number_of_active_nfts + 1, //Set the count to total + 1 
            address_of_depositor: ctx.sender(), //Address of the contract caller
            coin_balance: amount, //Pass by value Coin<T> from total coin_amount_as_coin
            coin_type: type_name::get<T>(), //Store Coin Type as string for extra metadata
            is_locked: true //Set locked state to true - this extra metadata just for extra security

            
        };
    

     //7. Emit a Treasury Deposit Event
    emit_deposit_event(&new_nft.id, &amount, &ctx.sender());


    //8. Transfer NFT over to sender
    transfer::transfer(new_nft, ctx.sender())

    }   

  //****** DEPOSIT FUNCTIONALITY - END **********/  


//

//****** WITHDRAWAL FUNCTIONALITY - START **********/   
//Expose public method to withdraw funds by returning minted NFT
    //NOTE the sui::object module doesn't contain a direct way to find the call of the function
    //3rd Params because we must manage the proxy relationship between the treasury and asset bank comms 
    //4th Params because accessing current transaction context is impossible without it
    #[allow(lint(self_transfer))]
    public fun withdraw<T: store + key>(bank: &mut AssetBank, receipt: Receipt<T>, treasury: &mut Treasury<T>, ctx: &mut TxContext) {
        //UPDATE - On reviewing the caller of the function needs to verified before state management
        //1. Check if we have an active treasury available for the for transaction handling
        
           
         
    
         let Receipt { id, coin_type:_, is_locked, coin_balance, address_of_depositor, nft_count: _ } = receipt;
         assert!(bank.is_treasury_initialised == true, GE_TREASURY_IS_NOT_INITIALISED);
        

        //2. Check that the intitialiser of the transaction is the allowed to do withdraw
        assert!(ctx.sender() == address_of_depositor, GE_UNAUTHORISED_USER_ACCESS);

        //3. Check if the Receipt<T>


        //3. Since the user has Receipt presented to us we can assume they have made a deposit
        //So read the amount deposited from the receipt and the address to create a withdraw event
        //Check the treasury for the user receipt - Even there are two receipts they will have two different UID's 
        let user = treasury.vault.contains(ctx.sender());
        //Because all receipts are burned after withdraw we can assume the user must have entry if the receipt is present
        //However just incase we check to see if there is user deposit 
        assert!(user == true, GE_USER_HAS_NO_FUNDS_IN_TREASURY);
        //Next we check if the receipt is claimed 
        //NOTE although all receipts will destory there will be no anti-state to clamied: true
        //But for safety we can check the nft locked state (claimed state is true)
        assert!(is_locked, GE_USER_NFT_IS_INVALID);

        //Destruct the Receipt
        // let Receipt<T> {id, coin_balance, is_locked, address_of_depositor, nft_count: _} = receipt;
        //If the true then we remove the value and store the info ready to sent to the user
         //This contains coin info as Coin<T>



       //Remove entry returns V - UserObjectStruct as a value
       //Passing address which is K to get the record removed - Removing the entry from the recorded
        let removed_user_entry_data = treasury.vault.remove(ctx.sender());

        // Split a `Balance` and take a sub balance from it.
        //public fun split<T>(self: &mut Balance<T>, value: u64): Balance<T> {
        //extract balance of x from treasury value by ref to u64 amount
    
        
        //4. Update the state of current nfts
        //Here I'm not do anything to the state of receipts count only active nfts 
        //nfts count be balanced asset bank other wise we go broke :)
        
        //Asset Bank
        bank.number_of_active_nfts = bank.number_of_active_nfts - 1;
        bank.total_treasury_balance = bank.total_treasury_balance - coin_balance;

     
        emit_withdraw_event(coin_balance, ctx, bank);
        //5. Destroy the receipt (NFT receipt object)
         //Public transfer to user since we are using the Coin<T>
         //Based of security rules around balances we can only send numerical value because

         
        transfer::public_transfer(removed_user_entry_data, ctx.sender());

        //6. Emit an appropriate withdrawal event - call the withdrawal emmit event
        //1st: u64, ctx, address
        //emit_withdraw_event(withdraw_amount: &u64, ctx: &mut TxContext, bank: &mut AssetBank)
       
        object::delete(id)
        //

    

    }





//****** WITHDRAWAL FUNCTIONALITY - END **********/   

    




//****** MAIN CONTRACT FUNCTIONAILITY - INITIALISERS **********/   

//****** SMART CONTRACT CONSTRUCTOR FUNCTION - START (ASSETBANK) **********/   
     fun init(_:BANK, ctx: &mut TxContext) {
        //Share the AssetBank Object with user to call the methods deposit and withdraw
        let asset_bank_id = object::new(ctx);
        let asset_bank = AssetBank {
            id: asset_bank_id, //Assign UID to register on Sui,
            number_of_deposits: 0,//Initial Deposit State is 0 on deployment
            number_of_active_nfts: 0,//Initial NFT Count state is 0 on deployment,
            admin: tx_context::sender(ctx), //Contract Initialiser -> Admin 
            is_treasury_initialised: false, //Default state false
            treasury_count: 0, //Set treasure count to zero
            total_treasury_balance: 0
        };
        // AssetBank Initialisation Event
         asset_bank_init_event(ctx, &asset_bank.id,  &asset_bank.number_of_deposits, &asset_bank.number_of_active_nfts,  &asset_bank.total_treasury_balance);
        //Make the Asset Bank Available
        transfer::share_object(asset_bank);
     }  
//****** SMART CONTRACT CONSTRUCTOR FUNCTION - END  (ASSETBANK) **********/   
//



//****** SMART CONTRACT CONSTRUCTOR FUNCTION - START (TREASURY) **********/ 

     //Extract mutable reference to the Asset Bank to extract the current property state
     #[allow(lint(self_transfer))]
     public fun init_treasury<T: store + key>(_treasury_witness: TREASURYWITNESS, bank: &mut AssetBank, ctx: &mut TxContext){
        //1. Check first the initialise of this function is admin to avoid issues
        assert!(bank.admin == ctx.sender(), GE_UNAUTHORISED_USER_ACCESS);
        //2. Check to make the treasury has not already been initialised so that we do create more than one asset bank
        assert!(bank.is_treasury_initialised == false, GE_TREASURY_IS_ALREADY_INITIALISED);
        //3. Check to make that there is only one treasure in existance
        assert!(bank.treasury_count == 1, GE_TREASURY_MAX_LIMIT);

        //Create the asset bank treasury facility
        //Params: treasury ID, 2nd Bank Id, 3rd T
        //OTW Pass here
        let treasury = create_treasury<T>(_treasury_witness,ctx, &bank.id);
        
        //4. Update the state of the asset bank
        bank.is_treasury_initialised = true; //treasury flag
        bank.treasury_count = 1;//Increment to max count for treasury 1
        //5. Emit a Treasury Init Event
        //&treasury.id - &UID, 
        //Move allows for &mut - & by param passing
        
        emit_treasury_init_event(&bank.id, &treasury.id);
        

         //6. Transfer admin power of the Treasury to the Asset Bank Initialiser
         transfer::transfer(treasury, ctx.sender())
        
        //7. Set the treasure counter 
     }
 //****** SMART CONTRACT CONSTRUCTOR FUNCTION - END (TREASURY) **********/    
        
    
    