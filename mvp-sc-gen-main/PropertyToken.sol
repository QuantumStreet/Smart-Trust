// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

        import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
        import "@openzeppelin/contracts/access/Ownable.sol";
        import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
        import "@openzeppelin/contracts/utils/math/SafeMath.sol";





                /// @title PropertyToken
                /// @dev Real Estate Property Tokenization Contract for Fractional Ownership
                contract PropertyToken is ERC20, Ownable, ReentrancyGuard {



                    // ================ State Variables ================
                        /// @dev Physical address of the property
                        string public propertyAddress;
                        /// @dev Total property value in USD
                        uint256 public propertyValue;
                        /// @dev Total number of tokens representing the property
                        uint256 public totalTokens;
                        /// @dev Price per token in USD
                        uint256 public tokenPrice;
                        /// @dev IPFS hash of property documents
                        bytes32 public propertyDocumentHash;
                        /// @dev Whether the property tokenization is active
                        bool public isActive;
                        /// @dev Monthly rental income in USD
                        uint256 public rentalIncome;
                        /// @dev Timestamp of last rental payment
                        uint256 public lastRentalPayment;

                    // ================ Events ================
                        /// @dev Emitted when property is tokenized
                        event PropertyTokenized(
                            string indexed propertyAddress, 
                            uint256 propertyValue, 
                            uint256 totalTokens
                        );
                        /// @dev Emitted when tokens are purchased
                        event TokensPurchased(
                            address indexed buyer, 
                            uint256 amount, 
                            uint256 totalCost
                        );
                        /// @dev Emitted when rental income is distributed
                        event RentalIncomeDistributed(
                            uint256 totalIncome, 
                            uint256 timestamp
                        );
                        /// @dev Emitted when property is sold
                        event PropertySold(
                            uint256 salePrice, 
                            address indexed buyer
                        );


                    // ================ Constructor ================
                    /// @dev Initialize the property tokenization contract
                    constructor(
                            string _propertyAddress, 
                            uint256 _propertyValue, 
                            uint256 _totalTokens, 
                            bytes32 _propertyDocumentHash, 
                            uint256 _rentalIncome
                    ) {
                        ERC20("Property Token", "PROP")
                        propertyAddress = _propertyAddress;
                        propertyValue = _propertyValue;
                        totalTokens = _totalTokens;
                        tokenPrice = _propertyValue / _totalTokens;
                        propertyDocumentHash = _propertyDocumentHash;
                        rentalIncome = _rentalIncome;
                        isActive = true;
                        _mint(msg.sender, _totalTokens);
                        emit PropertyTokenized(_propertyAddress, _propertyValue, _totalTokens);
                    }

                    // ================ Functions ================
                        /// @dev Allow users to purchase property tokens
                                /// @param amount Number of tokens to purchase
                        
                        function purchaseTokens(
                                uint256 amount
                        ) public nonReentrant {
                                require(isActive, "Property tokenization is not active");
                                require(amount > 0, "Amount must be greater than 0");
                                require(balanceOf(msg.sender) + amount <= totalSupply(), "Not enough tokens available");
                                uint256 totalCost = amount * tokenPrice;
                                require(msg.value >= totalCost, "Insufficient payment");
                                _transfer(owner(), msg.sender, amount);
                                if (msg.value > totalCost) {
                                    payable(msg.sender).transfer(msg.value - totalCost);
                                }
                                emit TokensPurchased(msg.sender, amount, totalCost);
                        }
                        /// @dev Distribute rental income to token holders proportionally
                        
                        function distributeRentalIncome(
                        ) public onlyOwner nonReentrant {
                                require(isActive, "Property tokenization is not active");
                                require(address(this).balance >= rentalIncome, "Insufficient rental income");
                                uint256 totalSupply = totalSupply();
                                for (uint256 i = 0; i < totalSupply; i++) {
                                    address holder = _getHolderAtIndex(i);
                                    uint256 balance = balanceOf(holder);
                                    uint256 share = (balance * rentalIncome) / totalSupply;
                                    if (share > 0) {
                                        payable(holder).transfer(share);
                                    }
                                }
                                lastRentalPayment = block.timestamp;
                                emit RentalIncomeDistributed(rentalIncome, block.timestamp);
                        }
                        /// @dev Sell the entire property and distribute proceeds to token holders
                                /// @param salePrice Sale price of the property
                                /// @param buyer Address of the property buyer
                        
                        function sellProperty(
                                uint256 salePrice, 
                                address buyer
                        ) public onlyOwner nonReentrant {
                                require(isActive, "Property tokenization is not active");
                                require(salePrice > 0, "Sale price must be greater than 0");
                                require(msg.value >= salePrice, "Insufficient payment");
                                uint256 totalSupply = totalSupply();
                                for (uint256 i = 0; i < totalSupply; i++) {
                                    address holder = _getHolderAtIndex(i);
                                    uint256 balance = balanceOf(holder);
                                    uint256 share = (balance * salePrice) / totalSupply;
                                    if (share > 0) {
                                        payable(holder).transfer(share);
                                    }
                                }
                                isActive = false;
                                emit PropertySold(salePrice, buyer);
                        }
                        /// @dev Get comprehensive property information
                        
                        function getPropertyInfo(
                        ) public view returns (string, uint256, uint256, uint256, bytes32, bool, uint256, uint256) {
                                return (
                                    propertyAddress,
                                    propertyValue,
                                    totalTokens,
                                    tokenPrice,
                                    propertyDocumentHash,
                                    isActive,
                                    rentalIncome,
                                    lastRentalPayment
                                );
                        }
                        /// @dev Get the percentage share of a token holder
                                /// @param holder Address of the token holder
                        
                        function getTokenHolderShare(
                                address holder
                        ) public view returns (uint256) {
                                uint256 balance = balanceOf(holder);
                                return (balance * 100) / totalSupply();
                        }
                        /// @dev Update the monthly rental income amount
                                /// @param newRentalIncome New monthly rental income amount
                        
                        function updateRentalIncome(
                                uint256 newRentalIncome
                        ) public onlyOwner {
                                require(newRentalIncome > 0, "Rental income must be greater than 0");
                                rentalIncome = newRentalIncome;
                        }
                        /// @dev Pause the property tokenization
                        
                        function pauseTokenization(
                        ) public onlyOwner {
                                isActive = false;
                        }
                        /// @dev Resume the property tokenization
                        
                        function resumeTokenization(
                        ) public onlyOwner {
                                isActive = true;
                        }

                    // ================ Receive Function ================
                    /// @dev Allow contract to receive ETH for rental income and property sales
                    receive() external payable {
                        // Contract can receive ETH
                    }

                }
             
         
     
 

