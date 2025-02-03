
# CHECKLIST

❌ - Not Complete
✅ - Complete
✔️ - Section Complete

# SECTION 1 ✔️✔️ Complies with Zero Errors ✔️

1. Create a Module call bank.move

2. Create init function that generate an asset bank and shares it publicly
    a. Create an Asset Bank Struct that can referenced on-chain ✅
    b. Create an init function (constructor function) that creates an asset bank ✅
    c. Transfer the object publicly ✅

3. Asset Bank Specification is that is that it must have
    - ID to make it a SUI object -> id: UID ✅
    - A Counter indicating the number of deposits made to the bank -> deposit_count ✅
    - A Counter indicating the current number of active NFTs (deposits) -> number_of_active_nfts ✅

# SECTION 2 - Create Deposit Functionality

## PART 2: Receipt Struct (Global) to transfer to call of the function - DEPOSIT EVENT✅ Complies with Zero Errors ✔️

Specification:

1. An ID that makes is a Global SUI object -> id: UID ✅
2. An integer indicating the number of this NFT -> nft_count: u64 ✅
3. It will have the address of the depositor -> depositor_address: address ✅
4. The Amount of the token deposited -> deposit_amount: u64 ✅
5. The type of the token deposited -> token_type: string ✅

# PART 2: Create a Method called Deposit that any user can invoke to deposit funds into the bank - deposit<T>(bank: &mut AssetBank, coin: Coin<T>, ctx: &mut TxContext)✅ - Complies with Zero Errors ✔️

Specification:

1. Revert if the balance of the provided coin object is ZERO✅
2. Take the user's coin and deposit it in the bank object.✅
3. Create an NFT receipt and transfer it to the caller. - PART 3✅
4. Increase the number of deposits.✅
5. Increase the number of active NFTs.✅
6. Emit an appropriate deposit event.✅

# SECTION 3 - Create Withdraw Functionality

1. Remove the balance equal to receipt.amount from the asset bank of the coin type T.
2. Convert the balance into a Coin and transfer it to the receipt depositor's address.
3. Decrease the number of active NFTs (depositors).
4. Destroy the receipt object.
5. Emit an appropriate withdrawal event
