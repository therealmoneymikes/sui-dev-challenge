

module bank::errors {

    /* Asset Bank State Error Messages*/
    //Global Error Code - GE
    
     const GEZERO_DEPOSIT_COUNT: u64 = 1000; //Error Condition when number_of_deposit is NOT zero
     
     const GEZERO_NFTS_COUNT: u64 = 1001; //Errr Condition when number_of_current_nfts is NOT zero

     const GEINVALID_ASSET_BANK_STATE: u64 = 1002; //Error Condition for incorrect or invalid bank state

    /* User Smart Contract Interactions */
  
     const GEZERO_USER_INSUFFICIENT_FUNDS: u64 = 1003; //Error Condition when user has insufficient coin funds
 
     const GEUNAUTHORISED_USER_ACCESS: u64 = 1004; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    
    

    /* Testing Environment Smart Contract Inteactions*/
    // Asset Bank State Testing on First User Interaction
 
     const TEASSET_BANK_COUNT_IS_NOT_ONE: u64 = 1005; 

     const TEASSET_NFT_COUNT_IS_NOT_ONE: u64 = 1006;

    //  Accessors Functions
    // Global Errors
    public fun ge_zero_deposit_count(): u64 {GEZERO_DEPOSIT_COUNT}
    public fun ge_zero_nfts_count(): u64 {GEZERO_NFTS_COUNT}
    public fun ge_invalid_asset_bank_state(): u64 {GEINVALID_ASSET_BANK_STATE}
    public fun ge_zero_user_insufficient_funds(): u64 {GEZERO_USER_INSUFFICIENT_FUNDS}
    public fun ge_unauthorised_user_acccess(): u64 {GEUNAUTHORISED_USER_ACCESS}
    //Test Errors Only
    public fun te_asset_bank_count_is_not_one(): u64 {TEASSET_BANK_COUNT_IS_NOT_ONE}
    public fun te_asset_nft_count_is_not_one(): u64 {TEASSET_NFT_COUNT_IS_NOT_ONE}
   

    
}