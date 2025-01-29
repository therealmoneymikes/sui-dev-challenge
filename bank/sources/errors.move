

//Global Error Files
// #[allow(unused_const)]
// module bank::errors {

//     /* Asset Bank State Error Messages*/
//     //Global Error Code - GE
//      #[error]
//      const GEZERO_DEPOSIT_COUNT: vector<u8> = b"Asset Bank's deposit count state is not zero"; //Error Condition when number_of_deposit is NOT zero
//      #[error]
//      const GEZERO_NFTS_COUNT: vector<u8> = b"Asset Bank's nfts count state is not zero"; //Error Condition when number_of_current_nfts is NOT zero
//      #[error]
//      const GEINVALID_ASSET_BANK_STATE: vector<u8> = b"Invalid Asset Bank state"; //Error Condition for incorrect or invalid bank state

//     /* User Smart Contract Interactions */
//      #[error]
//      const GEZERO_USER_INSUFFICIENT_FUNDS: vector<u8> = b"User has insufficient funds for transaction"; //Error Condition when user has insufficient coin funds
//      #[error]
//      const GEUNAUTHORISED_USER_ACCESS: vector<u8> = b"Unauthorised user access"; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    

//     /* Testing Environment Smart Contract Inteactions*/
//     // Asset Bank State Testing on First User Interaction
//      #[error]
//      const TEASSET_BANK_COUNT_IS_NOT_1: vector<u8> = b"Asset Bank's deposit count state is NOT one"; 
//      #[error]
//      const TEASSET_NFT_COUNT_IS_NOT_ONE: vector<u8> = b"Asset Bank's deposit count state is NOT one";

    
// }
module bank::errors {

    /* Asset Bank State Error Messages*/
    //Global Error Code - GE
     #[error]
     const GEZERO_DEPOSIT_COUNT: u64 = 1000; //Error Condition when number_of_deposit is NOT zero
     #[error]
     const GEZERO_NFTS_COUNT: u64 = 1001; //Errr Condition when number_of_current_nfts is NOT zero
     #[error]
     const GEINVALID_ASSET_BANK_STATE: u64 = 1002; //Error Condition for incorrect or invalid bank state

    /* User Smart Contract Interactions */
     #[error]
     const GEZERO_USER_INSUFFICIENT_FUNDS: u64 = 1003; //Error Condition when user has insufficient coin funds
     #[error]
     const GEUNAUTHORISED_USER_ACCESS: u64 = 1004; //Error Condition for unauthorised user actions e.g NFT transfers to another user
    

    /* Testing Environment Smart Contract Inteactions*/
    // Asset Bank State Testing on First User Interaction
     #[error]
     const TEASSET_BANK_COUNT_IS_NOT_1: u64 = 1005; 
     #[error]
     const TEASSET_NFT_COUNT_IS_NOT_ONE: u64 = 1006;

    
}