//https://yakitori.dev/blog/00-sui-move-for-solidity-devs/#object-ownership
#[allow(unused_use)]
module bank::bank {


    use sui::coin::{Self, Coin};
    use sui::event; //For Handling Events for NFT contract interaction
    use bank::errors;
    use sui::balance::{Self, Balance};
    use sui::bag::{Self, Bag};
    use sui::dynamic_field;
    
    use std::string::{String, utf8};
    use sui::url::{Self, Url};
    use sui::object::{new};
   
    use nft_tutorial::ownership::{OwnerCap};

    const MAX_SUPPLY: u64 = 100;

    
    
    // use sui::balance::{Self, Balance}

    //Asset Bank for NFT TX Data
    //Add Copy Trait to clone, Drop Trait = drop to end lifetime at the EOO, Copy Trait = copy on OO, Key for Sui Global Storage Operations

    //UID - id structure with type address and key traitID - General ID, Note to self: drop and copy conflicts with key
    
   
    public struct AssetBank has key, store {
        id: UID, //UID for AssetBank Unique 
        number_of_deposits: u64, //For tracking number of deposits to the bank
        number_of_current_nfts: u64, //For current of nft deposited in
        admin: address, //Admin of the Asset Bank Object
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
    //Claim state to avoid double spending along with no copy tra
    public struct Receipt<T> has key, store {
        id: UID, //Unique ID for NFT's the users receive
        nft_receipt_number: u64,
        address_of_depositor: address, //Address of the depositor (user)
        amount: u64, //Tokens Deposited Amount
        claimed: bool, //Claim State (set to true on creation)
    }

    //Contract Initation Function (Init)
    fun init(ctx: &mut TxContext) {
        //Create a new asset bank
        //Note to self: new returns ctx.fresh_object_address() as bytes prop for UIDid: UID, //UID for AssetBank Unique 

        let asset_bank = AssetBank {
            id: object::new(ctx), //Assign UID to register on Sui
            number_of_deposits: 0,//Initial Deposit State is 0 on deployment
            number_of_current_nfts: 0,//Initial NFT Count state is 0 on deployment
            admin: tx_context::sender(ctx), //Contract Initialiser -> Admin 
            balances: bag::new(ctx),//Initialize a new store table object to keep track of user balances
            receipts: bag::new(ctx),//Initialize a new store table object to keep track of receipts
        };

        //Share the AssetBank Object with user to call the methods deposit and withdraw
        transfer::share_object(asset_bank);
    
    }

    

    public struct Collection has key, store {
        id: UID,
        total_minted: u64,
    }

    public struct TestnetNFT has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
    }

    // events
    public struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        name: String,
    }

    // initialize collection
    public entry fun initialize_collection(
        _owner_cap: &OwnerCap,
        ctx: &mut TxContext
    ) {
        let pool = Collection {
            id: object::new(ctx),
            total_minted: 0,
        };

        // Share the collection object with the network
        transfer::share_object(pool);
    }

    public fun mint_to_sender(
        collection: &mut Collection,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(collection.total_minted < MAX_SUPPLY, 0);

        let sender = ctx.sender();
        let nft = TestnetNFT {
            id: new(ctx),
            name: utf8(name),
            description: utf8(description),
            url: url::new_unsafe_from_bytes(url),
        };

        collection.total_minted = collection.total_minted + 1;

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
        });

        transfer::public_transfer(nft, recipient);
    }

}
