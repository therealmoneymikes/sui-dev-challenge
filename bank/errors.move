

//Global Error Files

module bank::errors {

    /* Asset Bank State Error Messages*/
    //Custom Error Code
    const EZERO_DEPOSIT_COUNT: u8 = 1; //Error Condition when number_of_deposit is NOT zero
    const EZERO_NFTS_COUNT: u8 = 2; //Error Condition when number_of_current_nfts is NOT zero
    const EINVALID_ASSET_BANK_STATE: u8 = 3; //Error Condition for incorrect or invalid bank state

    /* User Smart Contract Interactions */
    const EZERO_USER_INSUFFICIENT_FUNDS: u8 = 4; //Error Condition when user has insufficient coin funds
    const EUNAUTHORISED_USER_ACCESS: u8 = 5; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    
}