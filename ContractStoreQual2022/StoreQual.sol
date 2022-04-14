// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract StoreQual{
    struct User{
        string Name;
        bytes32 PasswordHash;
        uint Balance;
        uint Role; // 0 - Admin, 1 - Seller, 2 - Buyer
        bool isUserExist;
    }
    
    mapping(address => User) private users;
    mapping(string => uint) public products;
    string[] productNames;

    constructor() {
        users[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = User("Admin", keccak256(abi.encodePacked("qwe")), 1000, 0, true);
        users[0x583031D1113aD414F02576BD6afaBfb302140225] = User("Seller", keccak256(abi.encodePacked("asd")), 1000, 1, true);
        users[0xdD870fA1b7C4700F2BD7f44238821C26f7392148] = User("Buyer", keccak256(abi.encodePacked("zxc")), 1000, 2, true);
    }

    // General Func
    function AuthUser(string memory Password) public view returns(bool) {
        require(users[msg.sender].isUserExist == true, "User not exist");
        
        if (users[msg.sender].PasswordHash == keccak256(abi.encodePacked(Password))) {
            return true;
        } else {
            return false;
        }
    }

    function RegUser(string memory Name, string memory Password) public {
        require(users[msg.sender].isUserExist == false, "User already exist");
        
        users[msg.sender] = (User(Name, keccak256(abi.encodePacked(Password)), 100, 0, true));
    }

    function GetProducts() public view returns(string[] memory) {
        return productNames;
    }

    function ViewBalance() public view returns(uint) {
        return users[msg.sender].Balance;
    }

    // Admin Func
    modifier onlyAdmin {
        require(users[msg.sender].Role == 0);
        _;
    }

    function PromotionToAdmin(address addressUser) public onlyAdmin{
        require(users[addressUser].isUserExist == true, "User not exist");
        
        users[addressUser].Role = 0;
    }

    function PromotionToSeller(address addressUser) public onlyAdmin{
        require(users[addressUser].isUserExist == true, "User not exist");
        require(users[addressUser].Role != 0, "User is Admin");

        users[addressUser].Role = 1;
    }

    function DemotionSellerToBuyer(address addressUser) public view onlyAdmin{
        require(users[addressUser].isUserExist == true, "User not exist");
        require(users[addressUser].Role == 1, "User not Seller");

        users[addressUser].Role == 2;
    }
    // Seller Func
    modifier onlySeller {
        require(users[msg.sender].Role == 1);
        _;
    }

    function AddNewProduct(string memory Name, uint Price) public onlySeller {
        require(products[Name] == 0, "Product is exist");
        require(Price > 0, "The price cannot be less than 0");

        products[Name] = Price;
        productNames.push(Name);
    }

    function EditProduct(string memory Name, uint Price) public onlySeller {
        require(products[Name] != 0, "Product not exist");
        require(Price > 0, "The price cannot be less than 0");

        products[Name] = Price;
    }
    // Buyer Func
    modifier onlyBuyer {
        require(users[msg.sender].Role == 2);
        _;
    }

    function BuyProduct(string memory Name) public onlyBuyer {
        require(products[Name] != 0, "Product not exist");
        require(products[Name] <= users[msg.sender].Balance, "No money");
    
        users[msg.sender].Balance -= products[Name];
    }
}