// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

        import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
        import "@openzeppelin/contracts/access/Ownable.sol";
        import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
        import "@openzeppelin/contracts/utils/math/SafeMath.sol";
        import "@openzeppelin/contracts/utils/Strings.sol";
        import "@openzeppelin/contracts/security/Pausable.sol";





                /// @title WyomingTrustTokenization
                /// @dev Wyoming Statutory Trust for Tokenized Single Family Residential Real Property - 1000 Year Perpetual Trust
                contract WyomingTrustTokenization is ERC721, Ownable, ReentrancyGuard, Pausable {

                    // ================ Structs ================
                        /// @dev Information about a trust property
                        struct PropertyInfo {
                            /// @dev Unique property identifier
                            uint256 propertyId;
                            /// @dev Physical address of the property
                            string propertyAddress;
                            /// @dev Fair market value of the property
                            uint256 propertyValue;
                            /// @dev Total square footage (property + structures)
                            uint256 totalSquareFootage;
                            /// @dev Total tokens for this property
                            uint256 tokenSupply;
                            /// @dev Tokens issued for this property
                            uint256 tokensIssued;
                            /// @dev Annual rental income
                            uint256 annualIncome;
                            /// @dev Annual expenses (taxes, insurance, maintenance)
                            uint256 annualExpenses;
                            /// @dev Net income after expenses
                            uint256 netIncome;
                            /// @dev Whether property is active in trust
                            bool isActive;
                            /// @dev IPFS hash of title documents
                            bytes32 titleDocumentHash;
                            /// @dev IPFS hash of appraisal documents
                            bytes32 appraisalDocumentHash;
                        }
                        /// @dev Information about a specific token
                        struct TokenInfo {
                            /// @dev Unique token identifier
                            uint256 tokenId;
                            /// @dev Property this token represents
                            uint256 propertyId;
                            /// @dev Square footage represented by this token
                            uint256 squareFootage;
                            /// @dev Fractional ownership percentage
                            uint256 fractionalOwnership;
                            /// @dev Whether token transfer was notarized
                            bool isNotarized;
                            /// @dev Hash of notarization document
                            bytes32 notarizationHash;
                            /// @dev Token creation timestamp
                            uint256 creationDate;
                        }
                        /// @dev Record of annual distributions
                        struct DistributionRecord {
                            /// @dev Unique distribution identifier
                            uint256 distributionId;
                            /// @dev Property for this distribution
                            uint256 propertyId;
                            /// @dev Distribution timestamp
                            uint256 distributionDate;
                            /// @dev Total amount distributed
                            uint256 totalDistributed;
                            /// @dev Amount per token
                            uint256 perTokenAmount;
                            /// @dev Amount allocated to reserve fund
                            uint256 reserveAllocation;
                        }


                    // ================ State Variables ================
                        /// @dev Name of the Wyoming Statutory Trust
                        string public trustName;
                        /// @dev Trust duration in years (1000 years)
                        uint256 public trustDuration;
                        /// @dev Trust start date timestamp
                        uint256 public trustStartDate;
                        /// @dev Address of the SETTLOR (Quantum Street, Inc.)
                        address public settlor;
                        /// @dev Address of the TRUSTEE
                        address public trustee;
                        /// @dev Address of the TRUST PROTECTOR
                        address public trustProtector;
                        /// @dev Address of the Wyoming qualified custodian
                        address public qualifiedCustodian;
                        /// @dev Total number of properties in the trust
                        uint256 public propertyCount;
                        /// @dev Total tokens issued across all properties
                        uint256 public totalTokensIssued;
                        /// @dev Balance of the trust reserve fund
                        uint256 public reserveFundBalance;
                        /// @dev Percentage of net profits distributed annually (90%)
                        uint256 public annualDistributionRate;
                        /// @dev Percentage allocated to reserve fund (10%)
                        uint256 public reserveFundRate;
                        /// @dev Minimum property value ($25,000,000)
                        uint256 public minimumPropertyValue;
                        /// @dev Token ownership threshold for visitation rights (30%)
                        uint256 public visitationThreshold;
                        /// @dev Timestamp of last annual distribution
                        uint256 public lastDistributionDate;
                        /// @dev Whether the trust is active
                        bool public isTrustActive;

                    // ================ Events ================
                        /// @dev Emitted when trust is established
                        event TrustEstablished(
                            string indexed trustName, 
                            address indexed settlor, 
                            address indexed trustee, 
                            uint256 duration
                        );
                        /// @dev Emitted when property is added to trust
                        event PropertyAdded(
                            uint256 indexed propertyId, 
                            string propertyAddress, 
                            uint256 propertyValue, 
                            uint256 tokenSupply
                        );
                        /// @dev Emitted when tokens are minted
                        event TokensMinted(
                            uint256 indexed propertyId, 
                            uint256[] tokenIds, 
                            address indexed recipient
                        );
                        /// @dev Emitted when token is transferred with notarization
                        event TokenTransferred(
                            uint256 indexed tokenId, 
                            address indexed from, 
                            address indexed to, 
                            bytes32 notarizationHash
                        );
                        /// @dev Emitted when annual distribution is made
                        event AnnualDistribution(
                            uint256 indexed propertyId, 
                            uint256 distributionDate, 
                            uint256 totalDistributed, 
                            uint256 perTokenAmount, 
                            uint256 reserveAllocation
                        );
                        /// @dev Emitted when reserve fund is updated
                        event ReserveFundUpdated(
                            uint256 newBalance, 
                            uint256 allocation
                        );
                        /// @dev Emitted when property income is updated
                        event PropertyIncomeUpdated(
                            uint256 indexed propertyId, 
                            uint256 annualIncome, 
                            uint256 annualExpenses, 
                            uint256 netIncome
                        );
                        /// @dev Emitted when trust protector is appointed
                        event TrustProtectorAppointed(
                            address indexed newProtector, 
                            address indexed previousProtector
                        );
                        /// @dev Emitted when trustee succession occurs
                        event TrusteeSuccession(
                            address indexed newTrustee, 
                            address indexed previousTrustee
                        );


                    // ================ Constructor ================
                    /// @dev Initialize the Wyoming Trust Tokenization contract
                    constructor(
                            string _trustName, 
                            address _settlor, 
                            address _trustee, 
                            address _trustProtector, 
                            address _qualifiedCustodian
                    ) {
                        ERC721("Wyoming Trust Property Tokens", "WTPT")
                        trustName = _trustName;
                        settlor = _settlor;
                        trustee = _trustee;
                        trustProtector = _trustProtector;
                        qualifiedCustodian = _qualifiedCustodian;
                        trustDuration = 1000;
                        trustStartDate = block.timestamp;
                        annualDistributionRate = 90;
                        reserveFundRate = 10;
                        minimumPropertyValue = 25000000 * 10**18;
                        visitationThreshold = 30;
                        isTrustActive = true;
                        emit TrustEstablished(_trustName, _settlor, _trustee, trustDuration);
                    }

                    // ================ Functions ================
                        /// @dev Add a new property to the trust
                                /// @param _propertyAddress Physical address of the property
                                /// @param _propertyValue Fair market value of the property
                                /// @param _totalSquareFootage Total square footage (property + structures)
                                /// @param _annualIncome Annual rental income
                                /// @param _titleDocumentHash IPFS hash of title documents
                                /// @param _appraisalDocumentHash IPFS hash of appraisal documents
                        
                        function addProperty(
                                string _propertyAddress, 
                                uint256 _propertyValue, 
                                uint256 _totalSquareFootage, 
                                uint256 _annualIncome, 
                                bytes32 _titleDocumentHash, 
                                bytes32 _appraisalDocumentHash
                        ) public onlyOwner nonReentrant {
                                require(_propertyValue >= minimumPropertyValue, "Property value below minimum");
                                require(_totalSquareFootage > 0, "Invalid square footage");
                                require(_annualIncome > 0, "Invalid annual income");
                                propertyCount++;
                                uint256 propertyId = propertyCount;
                                properties[propertyId] = PropertyInfo({
                                    propertyId: propertyId,
                                    propertyAddress: _propertyAddress,
                                    propertyValue: _propertyValue,
                                    totalSquareFootage: _totalSquareFootage,
                                    tokenSupply: _totalSquareFootage,
                                    tokensIssued: 0,
                                    annualIncome: _annualIncome,
                                    annualExpenses: 0,
                                    netIncome: _annualIncome,
                                    isActive: true,
                                    titleDocumentHash: _titleDocumentHash,
                                    appraisalDocumentHash: _appraisalDocumentHash
                                });
                                emit PropertyAdded(propertyId, _propertyAddress, _propertyValue, _totalSquareFootage);
                        }
                        /// @dev Mint tokens for a property
                                /// @param _propertyId Property ID to mint tokens for
                                /// @param _recipient Address to receive the tokens
                                /// @param _quantity Number of tokens to mint
                        
                        function mintTokens(
                                uint256 _propertyId, 
                                address _recipient, 
                                uint256 _quantity
                        ) public onlyOwner nonReentrant {
                                require(properties[_propertyId].isActive, "Property not active");
                                require(_quantity > 0, "Invalid quantity");
                                require(properties[_propertyId].tokensIssued + _quantity <= properties[_propertyId].tokenSupply, "Exceeds token supply");
                                uint256[] memory tokenIds = new uint256[](_quantity);
                                for (uint256 i = 0; i < _quantity; i++) {
                                    uint256 tokenId = totalTokensIssued + i + 1;
                                    _mint(_recipient, tokenId);
                                    tokens[tokenId] = TokenInfo({
                                        tokenId: tokenId,
                                        propertyId: _propertyId,
                                        squareFootage: 1,
                                        fractionalOwnership: (1 * 100) / properties[_propertyId].tokenSupply,
                                        isNotarized: false,
                                        notarizationHash: bytes32(0),
                                        creationDate: block.timestamp
                                    });
                                    tokenIds[i] = tokenId;
                                }
                                properties[_propertyId].tokensIssued += _quantity;
                                totalTokensIssued += _quantity;
                                emit TokensMinted(_propertyId, tokenIds, _recipient);
                        }
                        /// @dev Transfer token with notarization requirement
                                /// @param _tokenId Token ID to transfer
                                /// @param _to Recipient address
                                /// @param _notarizationHash Hash of notarization document
                        
                        function transferTokenWithNotarization(
                                uint256 _tokenId, 
                                address _to, 
                                bytes32 _notarizationHash
                        ) public nonReentrant {
                                require(_exists(_tokenId), "Token does not exist");
                                require(ownerOf(_tokenId) == msg.sender, "Not token owner");
                                require(_to != address(0), "Invalid recipient");
                                require(_notarizationHash != bytes32(0), "Notarization required");
                                address from = ownerOf(_tokenId);
                                tokens[_tokenId].isNotarized = true;
                                tokens[_tokenId].notarizationHash = _notarizationHash;
                                _transfer(from, _to, _tokenId);
                                emit TokenTransferred(_tokenId, from, _to, _notarizationHash);
                        }
                        /// @dev Update property income and expenses
                                /// @param _propertyId Property ID to update
                                /// @param _annualIncome New annual income
                                /// @param _annualExpenses New annual expenses
                        
                        function updatePropertyIncome(
                                uint256 _propertyId, 
                                uint256 _annualIncome, 
                                uint256 _annualExpenses
                        ) public onlyOwner {
                                require(properties[_propertyId].isActive, "Property not active");
                                require(_annualIncome >= _annualExpenses, "Expenses exceed income");
                                properties[_propertyId].annualIncome = _annualIncome;
                                properties[_propertyId].annualExpenses = _annualExpenses;
                                properties[_propertyId].netIncome = _annualIncome - _annualExpenses;
                                emit PropertyIncomeUpdated(_propertyId, _annualIncome, _annualExpenses, properties[_propertyId].netIncome);
                        }
                        /// @dev Distribute annual income to token holders
                                /// @param _propertyId Property ID for distribution
                        
                        function distributeAnnualIncome(
                                uint256 _propertyId
                        ) public onlyOwner nonReentrant {
                                require(properties[_propertyId].isActive, "Property not active");
                                require(properties[_propertyId].netIncome > 0, "No net income");
                                require(properties[_propertyId].tokensIssued > 0, "No tokens issued");
                                uint256 totalDistributed = (properties[_propertyId].netIncome * annualDistributionRate) / 100;
                                uint256 reserveAllocation = (properties[_propertyId].netIncome * reserveFundRate) / 100;
                                uint256 perTokenAmount = totalDistributed / properties[_propertyId].tokensIssued;
                                reserveFundBalance += reserveAllocation;
                                lastDistributionDate = block.timestamp;
                                uint256 distributionId = distributions.length;
                                distributions.push(DistributionRecord({
                                    distributionId: distributionId,
                                    propertyId: _propertyId,
                                    distributionDate: block.timestamp,
                                    totalDistributed: totalDistributed,
                                    perTokenAmount: perTokenAmount,
                                    reserveAllocation: reserveAllocation
                                }));
                                emit AnnualDistribution(_propertyId, block.timestamp, totalDistributed, perTokenAmount, reserveAllocation);
                                emit ReserveFundUpdated(reserveFundBalance, reserveAllocation);
                        }
                        /// @dev Get the percentage share of a token holder for a property
                                /// @param _propertyId Property ID
                                /// @param _holder Token holder address
                        
                        function getTokenHolderShare(
                                uint256 _propertyId, 
                                address _holder
                        ) public view returns (uint256) {
                                uint256 holderTokens = 0;
                                for (uint256 i = 1; i <= totalTokensIssued; i++) {
                                    if (_exists(i) && ownerOf(i) == _holder && tokens[i].propertyId == _propertyId) {
                                        holderTokens++;
                                    }
                                }
                                return (holderTokens * 100) / properties[_propertyId].tokensIssued;
                        }
                        /// @dev Check if holder has visitation rights (30%+ ownership)
                                /// @param _propertyId Property ID
                                /// @param _holder Token holder address
                        
                        function checkVisitationRights(
                                uint256 _propertyId, 
                                address _holder
                        ) public view returns (bool) {
                                uint256 share = getTokenHolderShare(_propertyId, _holder);
                                return share >= visitationThreshold;
                        }
                        /// @dev Get comprehensive property information
                                /// @param _propertyId Property ID
                        
                        function getPropertyInfo(
                                uint256 _propertyId
                        ) public view returns (PropertyInfo) {
                                return properties[_propertyId];
                        }
                        /// @dev Get token information
                                /// @param _tokenId Token ID
                        
                        function getTokenInfo(
                                uint256 _tokenId
                        ) public view returns (TokenInfo) {
                                require(_exists(_tokenId), "Token does not exist");
                                return tokens[_tokenId];
                        }
                        /// @dev Appoint new trust protector
                                /// @param _newProtector New trust protector address
                        
                        function appointTrustProtector(
                                address _newProtector
                        ) public onlyOwner {
                                require(_newProtector != address(0), "Invalid protector address");
                                address previousProtector = trustProtector;
                                trustProtector = _newProtector;
                                emit TrustProtectorAppointed(_newProtector, previousProtector);
                        }
                        /// @dev Appoint successor trustee
                                /// @param _newTrustee New trustee address
                        
                        function successorTrustee(
                                address _newTrustee
                        ) public onlyOwner {
                                require(_newTrustee != address(0), "Invalid trustee address");
                                address previousTrustee = trustee;
                                trustee = _newTrustee;
                                emit TrusteeSuccession(_newTrustee, previousTrustee);
                        }
                        /// @dev Pause trust operations
                        
                        function pauseTrust(
                        ) public onlyOwner {
                                isTrustActive = false;
                                _pause();
                        }
                        /// @dev Resume trust operations
                        
                        function unpauseTrust(
                        ) public onlyOwner {
                                isTrustActive = true;
                                _unpause();
                        }
                        /// @dev Get comprehensive trust information
                        
                        function getTrustInfo(
                        ) public view returns (string, address, address, address, address, uint256, uint256, uint256, bool) {
                                return (
                                    trustName,
                                    settlor,
                                    trustee,
                                    trustProtector,
                                    qualifiedCustodian,
                                    propertyCount,
                                    totalTokensIssued,
                                    reserveFundBalance,
                                    isTrustActive
                                );
                        }

                    // ================ Receive Function ================
                    /// @dev Allow contract to receive ETH for distributions and reserve fund
                    receive() external payable {
                        // Contract can receive ETH for distributions
                    }

                }
             
         
     
 

