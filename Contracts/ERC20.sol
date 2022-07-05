contract ERC20 {
    uint private creationTime = now;
  
    //States definition
    enum States {
        InTransition,
        Running 
    }
    States private state = States.Running;
  
    //Insert variable definitions
    uint256 public _totalSupply;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowed;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    //Transitions 
    function allowance (address owner, address spender) 
    public view   returns (uint remaining) 
    {
        require(state == States.Running);
        
        //State change
        state = States.InTransition;
        
        //Actions
        remaining = _allowed[owner][spender];   
        
        //State change
        state = States.Running; 
    }

    function approve (address spender, uint256 amount) 
    public   returns (bool success) 
    {
        require(state == States.Running);
        
        //Guards
        require((msg.sender != address(0)) && (spender != address(0)));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        _allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        success = true;
        
        //State change
        state = States.Running; 
    }

    function balanceOf (address owner) 
    public view   returns (uint256 balance) 
    {
        require(state == States.Running);
        
        //Guards
        require(owner != address(0));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        balance = _balances[owner];   
        
        //State change
        state = States.Running; 
    }

    function totalSupply () 
    public view   returns (uint256 supply) 
    {
        require(state == States.Running);
        
        //State change
        state = States.InTransition;
        
        //Actions
        supply = _totalSupply - _balances[address(0)];   
        
        //State change
        state = States.Running; 
    }

    function transfer (address to, uint256 amount) 
    public   returns (bool success) 
    {
        require(state == States.Running);
        
        //Guards
        require((to != address(0)) && (msg.sender != to));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer( msg.sender, to, amount);
        success = true;   
        
        //State change
        state = States.Running; 
    }

    function transferFrom (address from, address to, uint256 amount) 
    public   returns (bool success) 
    {
        require(state == States.Running);
        
        //Guards
        require((from != address(0)) && (to != address(0)));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        require(_balances[from] >= amount);
        require(_allowed[from][msg.sender] >= amount);
        _balances[from] = _balances[from] - amount;
        _allowed[from][msg.sender] = _allowed[from][msg.sender] - amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
        success = true;   
        
        //State change
        state = States.Running; 
    }
}