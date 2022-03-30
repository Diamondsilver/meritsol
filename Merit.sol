pragma solidity 0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract OmarCoin is ERC20, Ownable {

    
//usually the initial supply goes into the constructor and the ammount of tokens into the mint
    constructor() ERC20("Omar", "OMC") {
        _mint(msg.sender, 0);
    }

    mapping(address => bool) admins;
    mapping(address => bool) teachers;
    mapping(address => uint) coolDownTimer;
    mapping(address => uint) mintTimer;
    mapping(address => bool) NewOwnerElect;
    uint teacherCount;

    uint teacherAllowance = 150;
    uint maxTopUpAmount = 50;
    uint TeacherCoolDown = 2 weeks; 
    uint numberOfTeachers = 50;


    function setTimer(uint _time) private{
        uint cooldown = block.timestamp + _time;
        coolDownTimer[msg.sender] = cooldown;
    }

   

     function mintCooldown(address _address, uint _time) private{
        uint cooldown = block.timestamp + _time;
        mintTimer[_address] = cooldown;
    }


    /*function setTeacherAllowance(uint _amount) external onlyAdmin{
        teacherAllowance = _amount; 
    }

    function setMaxTopUp(uint _amount) external onlyAdmin{
        maxTopUpAmount = _amount;
    }

    function setCoolDownTime(uint _time) external onlyAdmin{
        TeacherCoolDown = _time;
    }*/

    function setAdmin(address _admin) external onlyAdmin{
        require(admins[_admin] == false,"User is already an admin");
        admins[_admin] = true;
    }

    function revokeAdmin(address _admin) external onlyAdmin{
        require(admins[_admin] == true,"User is not an admin");
        admins[_admin] = false;
    }

    function addTeacher(address _teacher) external onlyAdmin{
        require(teachers[_teacher] == false,"User already a teacher");
        require(teacherCount <= numberOfTeachers, "Over teacher limit, please remove old staff");
        teachers[_teacher] = true;
        teacherCount++;
        if(mintTimer[_teacher] < nowTime()){
         mintCooldown(_teacher, 52 weeks);
        _mint(address(_teacher), teacherAllowance);
        }
    }

    function removeTeacher(address _teacher) external onlyAdmin{
        require(teachers[_teacher]==true,"User is not a teacher");
        teachers[_teacher] = false;
        teacherCount--;
    }

    modifier onlyTeacher(){
        require(teachers[msg.sender] == true,"Access for teachers...");
        _;
    }

    function nowTime() private view returns(uint){ 
        uint timeNow = block.timestamp;
        return timeNow;
    }

    function teacherTopUp() external onlyTeacher{
       require(coolDownTimer[msg.sender] < nowTime(),"You must wait 2 weeks from your last top up");
        _mint(msg.sender, maxTopUpAmount);
        setTimer(TeacherCoolDown);
    }

    

    modifier onlyAdmin(){
        require(admins[msg.sender] == true || msg.sender == owner(),"Admin account needed");
        _;
    }

    function electNewOwner(address _newowner) external onlyOwner {
        require(NewOwnerElect[_newowner] = false,"Owner is already an elect");
        NewOwnerElect[_newowner] = true;
    }

    function unElectOwner(address _newowner) external onlyOwner {
        require(NewOwnerElect[_newowner] = true,"Owner is not an elect");
        NewOwnerElect[_newowner] = false;
    }


    function transferOwnerShip(address _newOwner) external onlyOwner {
        require(NewOwnerElect[_newOwner] == true,"");
        transferOwnership(_newOwner);
    }
  

    
}