pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GPTMembership is ERC721 {
    address public owner;
    uint256 public membershipTypes;
    uint256 public totalMemberships;

    string public MY_CONTRACT = "Caraibes CONNEXION";

    struct Membership {
        uint256 id;
        string name;
        uint256 cost;
        string date;
    }

    struct UserMembership {
        uint256 id;
        uint256 membershipId;
        address addressUser;
        uint256 cost;
        string expireDate;
    }

    mapping(address => UserMembership) public userMemberships;
    mapping(uint256 => Membership) public memberships;
    mapping(uint256 => mapping(uint256 => address[])) public membershipsTaken;

    modifier onlyOwner() {
        require(msg.sender == owner, "Seulement l'owner peut appeler cette fonction");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    function list(string memory _name, uint256 _cost, string memory _date) public onlyOwner() {
        membershipTypes++;
        memberships[membershipTypes] = Membership(
            membershipTypes,
            _name,
            _cost,
            _date
        );
    }

    function mint(uint256 _membershipId, address _user, string memory _expiredDate) public payable {
        require(_membershipId != 0);
        require(_membershipId <= membershipTypes);
        require(msg.value >= memberships[_membershipId].cost, "Balance insuffisante");

        totalMemberships++;

        userMemberships[_user] = UserMembership(
            totalMemberships,
            _membershipId,
            _user,
            memberships[_membershipId].cost,
            _expiredDate
        );

        membershipsTaken[_membershipId][totalMemberships].push(_user);

        _safeMint(_user, totalMemberships);
    }

    function getMemberships(uint256 _membershipId) public view returns (Membership memory) {
        return memberships[_membershipId];
    }

    function getMembershipsTaken(uint256 _membershipId) public view returns (address[] memory) {
        return membershipsTaken[_membershipId][totalMemberships];
    }

    function withdraw() public onlyOwner() {
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success);
    }

    function getUsermembership(address _address) public view returns (UserMembership memory) {
        return userMemberships[_address];
    }
}
