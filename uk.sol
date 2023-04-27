// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

contract MyToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address public controller; // address of the authorized controller
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        
        // initialize the authorized controller
        controller = msg.sender;
    }
    
    modifier onlyController() {
        require(msg.sender == controller, "Only the controller can call this function");
        _;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
    
    function mint(address account, uint256 amount) public override onlyController {
        require(account != address(0), "Cannot mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    
    function burn(address account, uint256 amount) public override onlyController {
        require(account != address(0), "Cannot burn from the zero address");
        require(amount <= _balances[account], "Insufficient balance to burn");
        _totalSupply -= amount;
        _balances[account] -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    function setController(address _controller) public onlyController {
        require(_controller != address(0), "Cannot set controller to the zero address");
        controller = _controller;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Cannot transfer from the zero address");
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(amount > 0), "Transfer amount must be greater than zero");
         require(amount <= _balances[sender], "Insufficient balance for transfer");
             _balances[sender] -= amount;
    _balances[recipient] += amount;
    
    emit Transfer(sender, recipient, amount);
}

function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "Cannot approve from the zero address");
    require(spender != address(0), "Cannot approve to the zero address");
    
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}

