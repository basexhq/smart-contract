// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
pragma experimental ABIEncoderV2;
import "./Address.sol";

// HANDY SHORTCUTS:
// address(0): 0x0000000000000000000000000000000000000000
// hash: keccak256(bytes("string"));

interface LightGTCRFactory {
    function deploy(
        address _arbitrator, // Simplifying from IArbitrator (no need for extra type, just using the address)
        bytes calldata _arbitratorExtraData,
        address _connectedTCR,
        string calldata _registrationMetaEvidence,
        string calldata _clearingMetaEvidence,
        address _governor,
        uint256[4] calldata _baseDeposits,
        uint256 _challengePeriodDuration,
        uint256[3] calldata _stakeMultipliers,
        address _relayContract
    ) external;

    function count() external view returns (uint256);
    function instances(uint256 _index) external view returns (address);
}

enum Status {
    Absent, // The item is not in the registry.
    Registered, // The item is in the registry.
    RegistrationRequested, // The item has a request to be added to the registry.
    ClearingRequested // The item has a request to be removed from the registry.
}

interface KlerosList {
    function addItem(string calldata _item) external payable;
    function getItemInfo(bytes32 _itemID) external view returns (Status status, uint256 numberOfRequests, uint256 sumDeposit);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function mint(address addr, uint256 num) external;
}

struct Organisation { 
    string orgGuid;
    string name; // See below. Even though data is stored on IPFS, we keep the name on-chain for convenience (manual debugging)
    string JSONIPFS; // Data about organisation is stored on IPFS
    address klerosAddress;
    address payoutWallet;
    uint256 PVT; // Before the payout wallet is set we accumulate PVT tokens here
    uint256 NVT;
    uint256 PVThistorical;
    uint256 NVThistorical;
}

struct Item { // Item can be either a Report or Evaluation
    string itemGuid;
    string targetGuid; // If Report: targetGuid is the guid of the org. If Evaluation: targetGuid is the guid of the report
    uint256 orgIndex;
    string JSONIPFS;
    uint256 PVT;
    uint256 NVT;
    bool approvedToKlerosAndTokensMinted; // after approval we can mint tokens and set to true
}

/* 
    THIS WILL LIVE IN THE IPFS STRUCTURE: 

    string title;
    string sourceURL;
    string fileIPFS;
    string comments;
    uint256: startDate;
    uint256: endDate;

    uint256 PVT;
    uint256 NVT;

    uint256 SDG1val;
    uint256 SDG2val;
    uint256 SDG3val;
    uint256 SDG4val;
    uint256 SDG5val;
    uint256 SDG6val;
    uint256 SDG7val;
    uint256 SDG8val;
    uint256 SDG9val;
    uint256 SDG10val;
    uint256 SDG11val;
    uint256 SDG12val;
    uint256 SDG13val;
    uint256 SDG14val;
    uint256 SDG15val;
    uint256 SDG16val;
    uint256 SDG17val;

    string SDG1comment;
    string SDG2comment;
    string SDG3comment;
    string SDG4comment;
    string SDG5comment;
    string SDG6comment;
    string SDG7comment;
    string SDG8comment;
    string SDG9comment;
    string SDG10comment;
    string SDG11comment;
    string SDG12comment;
    string SDG13comment;
    string SDG14comment;
    string SDG15comment;
    string SDG16comment;
    string SDG17comment;
*/

contract BaseX {

    address public admin;
    IERC20 public PVT;
    IERC20 public NVT;

    modifier adminOnly() {
        require(msg.sender == admin, "Restricted to admin");
        _;
    }

    LightGTCRFactory public klerosFactory;
    KlerosList public klerosOrganisations; // Global list of organisations (singleton)
    
    function initializer(address _klerosFactory, address _klerosOrganisations) public {
        require(admin == address(0), "Already initialised");
        admin = msg.sender;
        klerosFactory = LightGTCRFactory(_klerosFactory);
        klerosOrganisations = KlerosList(_klerosOrganisations);
    }

    Organisation[] public organisations;
    uint public organisationsLength;

    Item[] public items;
    uint public itemsLength;

    mapping (string => string) public guidLookup; // generated on the front-end, need to ensure they are unique
    mapping (string => uint) public orgGuidToIndex; 
    mapping (string => uint) public itemGuidToIndex;

    modifier newGuid(string memory guid, string memory name) {
      require(bytes(guidLookup[guid]).length == 0, "GUID already exists");
      guidLookup[guid] = name;
      _;
    }

    event OrganisationDeployed(string orgGuid, string name, address klerosAddress);
    event OrganisationAddedToKleros(string orgGuid, string name, address klerosAddress);
    event PayoutWalletAssigned(string orgGuid, string name, address payoutWallet);
    event ItemAdded(string orgGuid, string orgName, string itemGuid, uint itemIndex, string itemName, string itemJSONIPFS, uint PVT, uint NVT);
    event TokensMinted(string itemGuid, uint PVT, uint NVT);

    function deployOrganisation(string memory orgGuid, string memory name, string memory registrationJSONIPFS, string memory removingJSONIPFS) public newGuid(orgGuid, name) returns (uint256, address) {

        // factory.deploy(
        //         _arbitrator,
        //         _arbitratorExtraData,
        //         _connectedTCR,
        //         _registrationMetaEvidence,
        //         _clearingMetaEvidence,
        //         _governor,
        //         _baseDeposits,
        //         _challengePeriodDuration,
        //         _stakeMultipliers,
        //         _relayContract
        //     );

        klerosFactory.deploy(
            0x1128eD55ab2d796fa92D2F8E1f336d745354a77A,
            abi.encodePacked(bytes1(uint8(1))),
            0x0000000000000000000000000000000000000000,
            registrationJSONIPFS,
            removingJSONIPFS,
            // "/ipfs/QmcLd4ucxkU9TvjTUzKk2u2EzFcNV24UuvxwRq1JMhupmN/reg-meta-evidence.json",
            // "/ipfs/QmaiZUrRtKk1a12mW9zArG7TW1hXBraYB3u6AXwrrVGBH3/clr-meta-evidence.json",
            0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567,
            [uint256(0.05 ether), uint256(0.05 ether), 0, uint256(0.05 ether)],
            120, // 302400, // ----> for testing purposes we set the time to 120 (2 minutes) as opposed to 3.5 days, this is to test minting tokens after report is approved
            [uint256(10000), uint256(10000), uint256(20000)],
            0x0000000000000000000000000000000000000000
        );

        uint256 count = klerosFactory.count();
        address deployedOrg = klerosFactory.instances(count - 1);

        // Payout wallet is address(0) because it is not established yet (will be setup later on)
        Organisation memory organisation = Organisation(orgGuid, name, "", deployedOrg, address(0), 0, 0, 0, 0);
        organisations.push(organisation);
        orgGuidToIndex[orgGuid] = organisationsLength; // additional mapping for ease of access
        organisationsLength++;

        emit OrganisationDeployed(orgGuid, name, deployedOrg);

        return (organisationsLength - 1, deployedOrg); // returning index of the organisation and its address
    }

    // TLDR: the JSONIPFS contains the address of the organisation deployed in the previous step
    // In order to add organisation to the list we need to know its address
    // The address is contained inside the JSON that is uploaded to IPFS
    // It is possible to predict it but it can be problematic: https://github.com/kleros/gtcr/issues/296
    // For now, it is an acceptable UI / UX hurdle to require 2 transactions (one for deployment, one for adding)
    // Minor inconvenience: deploying and adding a new organisation will not happen very often 
    function addOrganisationToTheList(uint256 orgIndex, string memory organisationJSONIPFS) public payable {
        organisations[orgIndex].JSONIPFS = organisationJSONIPFS;
        klerosOrganisations.addItem{value: msg.value}(organisationJSONIPFS);

        emit OrganisationAddedToKleros(organisations[orgIndex].orgGuid, organisations[orgIndex].name, organisations[orgIndex].klerosAddress);
    }

    function getOrganisations() public view returns(Organisation[] memory) {
        return organisations;
    }

    function getOrganisation(uint256 index) public view returns (Organisation memory) {
        return organisations[index];
    }

    function getItems() public view returns(Item[] memory) {
        return items;
    }

    function getItem (uint256 index) public view returns (Item memory) {
        return items[index];
    }

    // TODO: Account abstraction
    // Currently, anyone can create an organisation to accrue PVT and NVT tokens
    // Then the admin can assign wallet to the organisation via face-to-face video call
    // Of course it is a surface of attack, seeking a better way. Feedback welcome.
    function assignPayoutWallet(uint256 orgIndex, address payoutWallet) public adminOnly {
        organisations[orgIndex].payoutWallet = payoutWallet;
        emit PayoutWalletAssigned(organisations[orgIndex].orgGuid, organisations[orgIndex].name, organisations[orgIndex].payoutWallet);
    }

    function addItem(string memory itemGuid, string memory itemName, string memory targetGuid, uint256 orgIndex, string memory JSONIPFS, uint256 PVTval, uint256 NVTval) public newGuid(itemGuid, itemName) payable {
        Item memory item = Item(itemGuid, targetGuid, orgIndex, JSONIPFS, PVTval, NVTval, false);
        items.push(item);
        itemGuidToIndex[itemGuid] = itemsLength; // additional mapping for ease of access
        itemsLength++;

        KlerosList orgitems = KlerosList(organisations[orgIndex].klerosAddress);
        orgitems.addItem{value: msg.value}(JSONIPFS);

        emit ItemAdded(organisations[orgIndex].orgGuid, organisations[orgIndex].name, itemGuid, itemsLength-1, itemName, JSONIPFS, PVTval, NVTval);
    }

    // After Kleros challenge process is finished and item is added to the list - we can then mint tokens
    function mintTokensAfterAdded(uint256 index) public {
        Item memory item = items[index];
        // ,, only interested in Status, skipping some data returned from the function that we don't need
        (Status status,,) = KlerosList(organisations[item.orgIndex].klerosAddress).getItemInfo(keccak256(bytes(item.JSONIPFS))); 
        
        require(status == Status.Registered, "Status should be Registered");
        require(item.approvedToKlerosAndTokensMinted == false, "PVT NVT already minted");
        require(organisations[item.orgIndex].payoutWallet != address(0), "Payout wallet not set");

        item.approvedToKlerosAndTokensMinted = true;
        organisations[item.orgIndex].PVThistorical += item.PVT;
        organisations[item.orgIndex].NVThistorical += item.NVT;
        PVT.mint(organisations[item.orgIndex].payoutWallet, item.PVT * 1 ether);
        NVT.mint(organisations[item.orgIndex].payoutWallet, item.NVT * 1 ether);

        emit TokensMinted(item.itemGuid, item.PVT, item.NVT);
    }

    function setupPVTNVT(address PVTaddr, address NVTaddr) public adminOnly {
        require(address(PVT) == address(0), "PVT already initialised");
        require(address(NVT) == address(0), "NVT already initialised");
        PVT = IERC20(PVTaddr);
        NVT = IERC20(NVTaddr);
    }

    // This is in case retrieval of multiple indices is needed: https://ethereum.stackexchange.com/a/151580/2524
    function multicall(bytes[] calldata data) external view returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionStaticCall(address(this), data[i]);
        }
        return results;
    }

    function getNameByGUID(string memory guid) external view returns(string memory) {
        return guidLookup[guid];
    }
    
}
