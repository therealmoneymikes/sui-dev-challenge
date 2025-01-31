module bank::ownership {
    use sui::event;

    //Admin struct to represent the Controller of the Asset Bank
    //Traits: key only 
    public struct AdminCap has key {
        id: UID
    }
    //NFTOwnerCap struct to represent the NFT Owner Capacity
    public struct NFTOwnerCap has key {
        id: UID
    }


    





}