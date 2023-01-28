// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";
import "./IPancakePair.sol";
import './IterableMapping.sol';
contract Presale is OwnableUpgradeable{ 
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;
    using IterableMapping for IterableMapping.Map;
    enum Status{
        upcoming,
        live,
        end,
        claimAllowed
    }     
    IERC20MetadataUpgradeable constant raiseToken=IERC20MetadataUpgradeable(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant public presaleToken=0xdAC17F958D2ee523a2206206994597C13D831ec7;
    IPancakeRouter02 public constant pancakeRouter =
        IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    uint16 constant totalRatio=1000;
    address[] public receivers;
    mapping(address=>uint16) public receiversRatio;
    uint16 public lockRatio;
    uint256 public presaleRatio;
    IterableMapping.Map private investors;
    Status public status;
    uint256 unlockDate;

    event StatusUpdated(uint indexed oldStatus, uint indexed newStatus);
    event Claimed(address indexed claimer, uint256 amount);
    event Bought(address indexed buyer, uint256 value);
    event RatioUpdated(
        address[] receivers,
        uint16[] ratios,
        uint256 presaleRatio,
        uint256 unlockDate
    );

    modifier isLive() {
        require(status==Status.live, "not live");
        _;
    }
    modifier isClaimable(){
        require(status==Status.claimAllowed, "not claimable");
        _;
    }
    function initialize(
        address[] memory _receivers,
        uint16[] memory _ratios,
        uint256 _presaleRatio,
        uint256 _unlockDate
    ) public initializer {
        require(_receivers.length==_ratios.length, "not same receiver and ratio count");
        require(_presaleRatio>0, "Ratio should be greater than 0");
        receivers=_receivers;
        uint16 _totalRatio;
        for(uint256 i=0;i<_receivers.length;i++){
            receiversRatio[_receivers[i]]=_ratios[i];
            _totalRatio+=_ratios[i];
        }
        lockRatio=totalRatio-_totalRatio;
        presaleRatio=_presaleRatio;
        status=Status.upcoming;
        unlockDate=_unlockDate;
        emit RatioUpdated(
            _receivers,
            _ratios,
            _presaleRatio,
            _unlockDate
        );
        __Ownable_init();
    }
    function updateRatio(
        address[] memory _receivers,
        uint16[] memory _ratios,
        uint256 _presaleRatio,
        uint256 _unlockDate
    ) external onlyOwner{
        require(_receivers.length==_ratios.length, "not same receiver and ratio count");
        receivers=_receivers;
        uint16 _totalRatio;
        for(uint256 i=0;i<_receivers.length;i++){
            receiversRatio[_receivers[i]]=_ratios[i];
            _totalRatio+=_ratios[i];
        }
        lockRatio=totalRatio-_totalRatio;
        presaleRatio=_presaleRatio;
        status=Status.upcoming;
        unlockDate=_unlockDate;
        emit RatioUpdated(
            _receivers,
            _ratios,
            _presaleRatio,
            _unlockDate
        );
    }
    function updateStatus(uint _status) external onlyOwner{
        require(_status>uint(status) && _status<4, "incorrect status");
        emit StatusUpdated(uint(status), _status);
        status=Status(_status);        
    }

    function unlock(address to) external onlyOwner{
        require(unlockDate<block.timestamp, "Lock period is not over yet!");
        raiseToken.safeTransfer(to, raiseToken.balanceOf(address(this)));
        (bool success, )=address(to).call{value: address(this).balance}("");
        require(success, "Refund Failed");
    }
    function buyWithETH() external payable isLive{
        require(msg.value > 0);       
        address[] memory path=new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(raiseToken);
        uint256[] memory amounts=pancakeRouter.getAmountsOut(msg.value, path);
        for(uint256 i=0;i<receivers.length;i++){
            if(receiversRatio[receivers[i]]>0){
                (bool success, )=address(receivers[i]).call{value: msg.value*receiversRatio[receivers[i]]/totalRatio}("");
            }
        }
        investors.invest(msg.sender, amounts[1]);
        emit Bought(msg.sender, amounts[1]);
    }

    function buyWithToken(uint256 _amount) external isLive{
        require(_amount > 0);
        raiseToken.safeTransferFrom(msg.sender, address(this), _amount);
        for(uint256 i=0;i<receivers.length;i++){
            if(receiversRatio[receivers[i]]>0){
                raiseToken.safeTransfer(receivers[i], _amount*receiversRatio[receivers[i]]/totalRatio);
            }
        }
        investors.invest(msg.sender, _amount);
        emit Bought(msg.sender, _amount);
    }

    function claim() external isClaimable{
        (uint256 value, , )=investors.get(msg.sender);
        uint256 amount=value*presaleRatio/(10**raiseToken.decimals());
        IERC20MetadataUpgradeable(presaleToken).safeTransfer(msg.sender, amount);
        investors.claim(msg.sender);
        emit Claimed(msg.sender, amount);
    }

    function getInvestorList() external view returns(address[] memory){
        return investors.getKeys();
    }

    function getInvestor(address _investor) external view returns(uint256 value, bool isInvest, bool isClaimed){
        (value, isInvest, isClaimed)=investors.get(_investor);
    }

    
}
