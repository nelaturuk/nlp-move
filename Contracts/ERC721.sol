contract ERC721 {
    uint private creationTime = now;

    //States definition
    enum States {
        InTransition,
        Running
    }
    States private state = States.Running;
    
    //Insert variable definitions
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    //Transitions 
    function approve (address approver, uint256 tokenId) 
    external payable  
    {
        require(state == States.Running);
        
        //Guards
        require((_owners[tokenId] != address(0)) && (approver != _owners[tokenId]));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        bool approvedOrAuthorized = msg.sender == _owners[tokenId] || _operatorApprovals[_owners[tokenId]][msg.sender];
        require(approvedOrAuthorized);
        _tokenApprovals[tokenId] = approver;
        emit Approval(_owners[tokenId], approver, tokenId);   
        
        //State change
        state = States.Running; 
    }

    function balanceOf (address owner) 
    external view   returns (uint256 balance) 
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

    function getApproved (uint256 tokenId) 
    external view   returns (address approved_address) 
    {
        require(state == States.Running);
        
        //Guards
        require(_owners[tokenId] != address(0));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        approved_address = _tokenApprovals[tokenId];   
        
        //State change
        state = States.Running; 
    }

    function isApprovedForAll (address owner, address operator) 
    external view   returns (bool approved) 
    {
        require(state == States.Running);
        
        //State change
        state = States.InTransition;
        
        //Actions
        approved = _operatorApprovals[owner][operator];   
        
        //State change
        state = States.Running; 
    }

    function ownerOf (uint256 tokenId) 
    external view   returns (address owner) 
    {
        require(state == States.Running);
        
        //Guards
        require(_owners[tokenId] != address(0));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        owner = _owners[tokenId];   
        
        //State change
        state = States.Running; 
    }

    function setApprovalForAll (address operator, bool approved) 
    external  
    {
        require(state == States.Running);
        
        //Guards
        require(msg.sender != operator);   
        
        //State change
        state = States.InTransition;
        
        //Actions
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);   
        
        //State change
        state = States.Running; 
    }

    function transferFrom (address from, address to, uint256 tokenId) 
    external payable  
    {
        require(state == States.Running);
        
        //Guards
        require((_owners[tokenId] != address(0)) && (to != address(0)) && (_owners[tokenId] == from));   
        
        //State change
        state = States.InTransition;
        
        //Actions
        bool ownedOrApprovedOrAuthorized = msg.sender == from || msg.sender == _tokenApprovals[tokenId] || _operatorApprovals[from][msg.sender];
        require(ownedOrApprovedOrAuthorized);
        _tokenApprovals[tokenId] = address(0);
        emit Approval(_owners[tokenId], address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        
        //State change
        state = States.Running; 
    }

}