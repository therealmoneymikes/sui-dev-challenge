

//Global Error Files
#[allow(unused_const)]
module bank::errors {

    /* Asset Bank State Error Messages*/
    //Global Error Code - GE
     const GEZERO_DEPOSIT_COUNT: vector<u8> = b"Asset Bank's deposit count state is not zero"; //Error Condition when number_of_deposit is NOT zero
     const GEZERO_NFTS_COUNT: vector<u8> = b"Asset Bank's nfts count state is not zero"; //Error Condition when number_of_current_nfts is NOT zero
     const GEINVALID_ASSET_BANK_STATE: vector<u8> = b"Invalid Asset Bank state"; //Error Condition for incorrect or invalid bank state

    /* User Smart Contract Interactions */
     const GEZERO_USER_INSUFFICIENT_FUNDS: vector<u8> = b"User has insufficient funds for transaction"; //Error Condition when user has insufficient coin funds
     const GEUNAUTHORISED_USER_ACCESS: vector<u8> = b"Unauthorised user access"; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    

    /* Testing Environment Smart Contract Interactions*/
    // Asset Bank State Testing on First User Interaction
     const TEASSET_BANK_COUNT_IS_NOT_1: vector<u8> = b"Asset Bank's deposit count state is NOT one"; 
     const TEASSET_NFT_COUNT_IS_NOT_ONE: vector<u8> = b"Asset Bank's deposit count state is NOT one";

    
}