#[test_only]
module bank::bank_tests {
    use bank::bank; //Bank module scope to extract test function
    use sui::tx_context; //Transaction context
    use sui::coin; //Coin types
    use sui::test_scenario; //test_scenario functions 
    use bank::errors; // Global Errors Module
    
    



    //1. Test Asset Bank Initialisation
    #[test]
    fun test_asset_bank_initialisation() {
        let sender_address = @0x0;
        let new_test_scenario = test_scenario::begin(&sender_address);//Scenario Object Generation

        //Test Scenario Transaction Context
        let ctx = test_scenario::ctx(&mut new_test_scenario); //Pass mut ref new test scenario

        //Call AssetBank init function from bank mod 
        bank::init(ctx); //Pass mut context object

        //Scenario - Assert that initial asset bank state for nft count and deposit count should be 0
        let asset_bank = test_scenario::take_shared<bank::AssetBank>(&new_test_scenario);

        assert!(asset_bank.number_of_deposits == 0, bank::errors::GEZERO_DEPOSIT_COUNT);//number of deposit should be zero
        assert!(asset_bank.number_of_current_nfts == 0, bank::errors::GEZERO_NFTS_COUNT);//number of nfts should be zero

        //Retrieve asset_bank object to the owner by value - End Taken state
        test_scenario::return_shared(asset_bank);

        //Test complete
        test_scenario::end(new_test_scenario);


    }

    //2. Test Deposit Zero Tokens Faliure
    #[test]
    #[expected_failure]
    fun test_user_depositing_zero_tokens_fails(){
        let start_address = @0x0;
        let admin_address = @0x1;
        let test_user_address = @0x2;

        let scenario = test_scenario::begin(start_address);//
        
      


        //Initialise Asset Bank Contract 
        let test_admin = test_scenario::next_tx(&mut scenario, admin_address); //1st Tx by admin
        let asset_bank = bank::init(&test_admin);

        //Simulation of test_user having no coins 
        let test_user = test_scenario::next_tx(&mut scenario, test_user_address);//2nd Tx by user 
        let test_user_coins = coin::mint(&test_user, 0); //No coins minted

        //Simulate user depositing zero coins into the asset bank 
        bank::deposit(&mut asset_bank, test_user_coins, &test_user);

        //Asset Bank State - Deposit Count, NFT count
        test_scenario::end(scenario);

    }

    #[test]
    fun test_user_depositing_successfully(){
        let start_address = @0x0;
        let admin_address = @0x1;
        let test_user_address = @0x2;

        let scenario = test_scenario::begin(@0x0);

        //Initialise of Asset Bank Contract
        let test_admin = test_scenario::next_tx(&mut scenario, admin_address); //1st Tx by admin
        let asset_bank = bank::init(&test_admin);

        //User deposits a valid coin amount
        let user = test_scenario::next_tx(&mut scenario, test_user_address);
        let test_user_coins = coin::mint(&test_user, 50); //No coins minted

        //Asserting whether n.o.d and nft count are both 1
        assert!(asset_bank.number_of_deposits == 1, bank::errors::TEASSET_BANK_COUNT_IS_NOT_ONE);
        assert!(asset_bank.number_of_current_nfts == 1, bank::errors::TEASSET_NFT_COUNT_IS_NOT_ONE);
        
        test_scenario::end(scenario);
    
    }
   

}