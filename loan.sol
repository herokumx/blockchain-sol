pragma solidity ^0.4.11;

//Demo Automobile Contract for the Heroku Blockchain Add-On
contract Automobile{

     string  make;
     string  model;
     string  year;
     string  VIN;
     uint price;
}
//Demo Automobile Contract (About the Car) for the Heroku Blockchain Add-On
contract Car is Automobile{
    //About the CAR
    address public owner;
    uint public numberOfAccidents;
    uint public numberOfServices;
    string[] public historyOfAccidents;
    string[] public serviceRecords;

    function  Car(
      string _make,
      string _model,
      string _year,
      uint _price,
      string _VIN,
      address preferredLender) public {
        make = _make;
        model = _model;
        year = _year;
        price = _price;
        owner = msg.sender;
        VIN = _VIN;
        addPreferredLender(preferredLender);
    }

    function carDetails() public constant returns (string,string,string,string,uint){
        return (VIN,make,model,year,price);
    }

    function buyCar() public payable {
      if( (msg.value / 1000000000000000000) >= price){
        owner.transfer(msg.value);
        owner = msg.sender;
      }else {
        revert();
      }
    }

    function addAccident(string description) public {
        historyOfAccidents.push(description);
        numberOfAccidents = numberOfAccidents + 1;
    }

    function addServiceRecord(string description) public {
        serviceRecords.push(description);
        numberOfServices = numberOfServices + 1;
    }

    //Demo Loan Program for Heroku Blockchain Add-On (About the Lien)
    address public lienHolder;
    uint public outStandingLoanOnCar;
    uint public monthlyDue;

    modifier ownerOnly(){
      if(msg.sender != owner){
        revert();
      }else{
        _;
      }
    }

    mapping (address => LienDetails) public lienDetails;

    struct LienDetails {
      bool active;
      uint since;
      uint256 loanAmount; //Ether or $
    }

    function addPreferredLender(address _lienHolder) public ownerOnly {
        lienDetails[_lienHolder] = LienDetails({active: true,since: now,loanAmount: 0});

    }

    function setDebt(uint _loan, uint _monthlyDue) public {

          if(lienDetails[msg.sender].active = true){
            lienDetails[msg.sender].loanAmount = _loan;
            outStandingLoanOnCar =  _loan;
            monthlyDue = _monthlyDue;
            lienHolder = msg.sender;
          }else {
            revert();
          }


    }

    function reviseTotalDue(uint _money) internal{

          outStandingLoanOnCar =  outStandingLoanOnCar - _money;
          if(outStandingLoanOnCar == 0){
            lienDetails[msg.sender].active = false;
            lienHolder = address(0);
            outStandingLoanOnCar = 0;
          }

    }

    function payMonthlyDue() public payable {
      reviseTotalDue(msg.value / 1000000000000000000);
      lienHolder.transfer(msg.value) ;
    }
}

//Demo Loan for Heroku Blockchain Add-On (About the Loan Program)

contract LoanProgram {

    string public nameOfLoan;
    address public owner;
    event FundsTransfered(address from, address to, uint quantity);
    uint private loanAmountInWei;

    function LoanProgram(string _name) public payable{
      nameOfLoan = _name;
      owner = msg.sender;
      FundsTransfered(msg.sender, this, msg.value);
    }
    
    function () public payable {
      FundsTransfered(msg.sender, this, msg.value);
    }

      modifier bankOnly(){
        if(msg.sender != owner){
          revert();
        }else{
          _;
        }
      }

    function lend(uint _loanAmount,address _borrowerId,address _borrowerAssetId, uint _loanRepaymentPeriod) public bankOnly {
      loanAmountInWei = _loanAmount * 1000000000000000000;
      _borrowerId.transfer(loanAmountInWei);
      Car car = Car (_borrowerAssetId);
      car.setDebt(_loanAmount, _loanAmount / _loanRepaymentPeriod);
    }



}
