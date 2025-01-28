

//Global Error Files
#[allow(unused_const)]
module bank::errors {

    /* Asset Bank State Error Messages*/
    //Global Error Code - GE
     const GEZERO_DEPOSIT_COUNT: u8 = 1; //Error Condition when number_of_deposit is NOT zero
     const GEZERO_NFTS_COUNT: u8 = 2; //Error Condition when number_of_current_nfts is NOT zero
     const GEINVALID_ASSET_BANK_STATE: u8 = 3; //Error Condition for incorrect or invalid bank state

    /* User Smart Contract Interactions */
     const GEZERO_USER_INSUFFICIENT_FUNDS: u8 = 4; //Error Condition when user has insufficient coin funds
     const GEUNAUTHORISED_USER_ACCESS: u8 = 5; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    

    /* Testing Environment Smart Contract Interactions*/
    // Asset Bank State Testing on First User Interaction
     const TEASSET_BANK_COUNT_IS_NOT_1: u8 = 6; 
     const TEASSET_NFT_COUNT_IS_NOT_ONE: u8 = 7;

    
}