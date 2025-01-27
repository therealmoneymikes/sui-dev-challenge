#[test_only]
module bank::bank_tests {
    use bank::bank; //Bank module scope to extract test function
    use sui::tx_context; //Transaction context
    use sui::coin; //Coin types
    use sui::test_scenario; //test_scenario functions 

    //Custom Error Code
    const EZERO_DEPOSIT_COUNT: u64 = 1; //Error Condition when number_of_deposit is NOT zero
    const EZERO_NFTS_COUNT: u64 = 2; //Error Condition when number_of_current_nfts is NOT zero
    



    //1. Test Asset Bank Initialisation
    #[test]
    fun initialise_asset_bank() {
        let sender_address = @0x0;
        let new_test_scenario = test_scenario::begin(&sender_address);//Scenario Object Generation

        //Test Scenario Transaction Context
        let ctx = test_scenario::ctx(&mut new_test_scenario); //Pass mut ref new test scenario

        //Call AssetBank init function from bank mod 
        bank::init(&ctx); //Pass mut context object

        //Scenario - Assert that initial asset bank state for nft count and deposit count should be 0
        let asset_bank = test_scenario::take_shared<bank::AssetBank>(&new_test_scenario);

        assert!(asset_bank.number_of_deposits == 0, EZERO_DEPOSIT_COUNT);//number of deposit should be zero
        assert!(asset_bank.number_of_current_nfts == 0, EZERO_NFTS_COUNT);//number of nfts should be zero

        //Retrieve asset_bank object to the owner by value
        test_scenario::return_shared(asset_bank);

        //Test complete
        test_scenario::end(new_test_scenario);


    }

}