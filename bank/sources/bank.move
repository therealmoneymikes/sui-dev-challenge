module bank::bank {

    use std::string::{Self, String}; //String Package for Self and String - String defs
    use sui::object::{Self, ID}; //Object package for Self an UID for SUI Unique ID
    use sui::transfer; //Transfer mod for transfers txs
    use sui::tx_content::{Self, TxContext}; //Self obj and TxContent obj
    use sui::event; //For Handling Events for NFT contract interaction
    
//Vec length is 1001 < 
//Rust move = Sui Move Hop...


    //Asset Bank for NFT TX Data
    //Add Copy Trait to clone 
    //Drop Trait = drop to end lifetime at the EOO
    //Copy Trait = copy on OO
    //Key for Sui Global Storage Operations

    struct AssetBank has key, copy, drop {
        id: ID, //UID for AssetBank Unique 
        number_of_deposits: u64, //For tracking number of deposits to the bank
        number_of_current_nfts: u64 //For current of nft deposited in
    }

    //Deposit event - Needs Drop Trait
    struct NFTDepositEvent has drop {
        asset_bank_id: ID, //Asset bank ID 
        deposit_amount: u64, //Deposit amount 
        address_of_depositor: address //Address of the depositor
    }

    
}
