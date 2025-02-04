// #[test_only]
// module bank::bank_tests {
//     use sui::test_scenario;
//     use sui::coin;
//     use sui::balance;
//     use sui::tx_context;
//     use std::string;
//     use bank::bank;
    
//     const ADMIN = @0xADMIN;
//     const USER = @0xUSER;
    

//     #[test] //Testing the initialisation of the ast
//     fun test_asset_bank_init() {
//         let scenario = test_scenario::begin(ADMIN);
//         let ctx = test_scenario::ctx(&mut scenario);
        
//         // Initialize AssetBank
//         bank::init(ctx);
        
//         test_scenario::next_tx(&mut scenario, ADMIN);
//         let asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
        
//         // Verify initial state
//         assert!(bank::get_admin(&asset_bank) == &ADMIN, 0);
//         assert!(bank::get_deposits(&asset_bank) == &0, 1);
//         assert!(bank::get_number_of_active_nfts(&asset_bank) == &0, 2);
//         assert!(!bank::is_treasury_initialised(&asset_bank), 3);
        
//         test_scenario::return_shared(asset_bank);
//         test_scenario::end(scenario);
//     }

//     #[test]
//     fun test_treasury_init() {
//         let scenario = test_scenario::begin(ADMIN);
//         let ctx = test_scenario::ctx(&mut scenario);
//         bank::init(ctx);
        
//         test_scenario::next_tx(&mut scenario, ADMIN);
//         let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//         bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
        
//         // Verify treasury initialized
//         assert!(bank::is_treasury_initialised(&asset_bank), 0);
//         assert!(bank::treasury_count(&asset_bank) == &1, 1);
        
//         test_scenario::return_shared(asset_bank);
//         test_scenario::end(scenario);
//     }

//     // #[test]
//     // #[expected_failure(abort_code = 1004)] // GE_TREASURY_IS_ALREADY_INITIALISED
//     // fun test_double_treasury_init() {
//     //     let scenario = test_scenario::begin(ADMIN);
//     //     let ctx = test_scenario::ctx(&mut scenario);
//     //     bank::init(ctx);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
        
//     //     // Attempt second initialization
//     //     bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
        
//     //     test_scenario::return_shared(asset_bank);
//     //     test_scenario::end(scenario);
//     // }

//     // #[test]
//     // fun test_deposit() {
//     //     let scenario = test_scenario::begin(ADMIN);
//     //     let ctx = test_scenario::ctx(&mut scenario);
//     //     bank::init(ctx);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
//     //     let mut treasury = test_scenario::take_owned<bank::Treasury<coin::SUI>>(&scenario);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let coin = coin::mint_for_testing(100, ctx);
//     //     bank::deposit(&mut asset_bank, coin, &mut treasury, ctx);
        
//     //     // Verify state changes
//     //     assert!(bank::get_deposits(&asset_bank) == &1, 0);
//     //     assert!(bank::get_number_of_active_nfts(&asset_bank) == &1, 1);
//     //     assert!(bank::total_treasury_balance(&asset_bank) == &100, 2);
        
//     //     test_scenario::return_shared(asset_bank);
//     //     test_scenario::return_owned(treasury);
//     //     test_scenario::end(scenario);
//     // }

//     // #[test]
//     // #[expected_failure(abort_code = 1006)] // GE_ZERO_USER_INSUFFICIENT_FUNDS
//     // fun test_deposit_zero_amount() {
//     //     let scenario = test_scenario::begin(ADMIN);
//     //     let ctx = test_scenario::ctx(&mut scenario);
//     //     bank::init(ctx);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
//     //     let mut treasury = test_scenario::take_owned<bank::Treasury<coin::SUI>>(&scenario);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let coin = coin::mint_for_testing(0, ctx);
//     //     bank::deposit(&mut asset_bank, coin, &mut treasury, ctx);
        
//     //     test_scenario::return_shared(asset_bank);
//     //     test_scenario::return_owned(treasury);
//     //     test_scenario::end(scenario);
//     // }

//     // #[test]
//     // fun test_withdraw() {
//     //     let scenario = test_scenario::begin(ADMIN);
//     //     let ctx = test_scenario::ctx(&mut scenario);
//     //     bank::init(ctx);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
//     //     let mut treasury = test_scenario::take_owned<bank::Treasury<coin::SUI>>(&scenario);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let coin = coin::mint_for_testing(100, ctx);
//     //     bank::deposit(&mut asset_bank, coin, &mut treasury, ctx);
//     //     let receipt = test_scenario::take_owned<bank::Receipt<coin::SUI>>(&scenario);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     let mut treasury = test_scenario::take_owned<bank::Treasury<coin::SUI>>(&scenario);
//     //     bank::withdraw(&mut asset_bank, receipt, &mut treasury, ctx);
        
//     //     // Verify withdrawal effects
//     //     assert!(bank::get_number_of_active_nfts(&asset_bank) == &0, 0);
//     //     assert!(bank::total_treasury_balance(&asset_bank) == &0, 1);
        
//     //     test_scenario::return_shared(asset_bank);
//     //     test_scenario::return_owned(treasury);
//     //     test_scenario::end(scenario);
//     // }

//     // #[test]
//     // #[expected_failure(abort_code = 1007)] // GE_UNAUTHORISED_USER_ACCESS
//     // fun test_unauthorized_withdraw() {
//     //     let scenario = test_scenario::begin(ADMIN);
//     //     let ctx = test_scenario::ctx(&mut scenario);
//     //     bank::init(ctx);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     bank::init_treasury<coin::SUI>(&mut asset_bank, ctx);
//     //     let mut treasury = test_scenario::take_owned<bank::Treasury<coin::SUI>>(&scenario);
        
//     //     test_scenario::next_tx(&mut scenario, ADMIN);
//     //     let coin = coin::mint_for_testing(100, ctx);
//     //     bank::deposit(&mut asset_bank, coin, &mut treasury, ctx);
//     //     let receipt = test_scenario::take_owned<bank::Receipt<coin::SUI>>(&scenario);
        
//     //     // Attempt withdraw with different user
//     //     test_scenario::next_tx(&mut scenario, USER);
//     //     let mut asset_bank = test_scenario::take_shared<bank::AssetBank>(&scenario);
//     //     let mut treasury = test_scenario::take_owned<bank::Treasury<coin::SUI>>(&scenario);
//     //     bank::withdraw(&mut asset_bank, receipt, &mut treasury, ctx);
        
//     //     test_scenario::return_shared(asset_bank);
//     //     test_scenario::return_owned(treasury);
//     //     test_scenario::end(scenario);
//     // }
// }