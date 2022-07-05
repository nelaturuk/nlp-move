module Evm::ERC721 {

    //Imports
    use Evm::Evm::{sender, self, sign, emit};
    use Evm::Table::{Self, Table};
    use Evm::U256::{Self, U256};

    //Base Resource
    resource struct ERC721_res {
        currState : vector<u8>
    }

    //Insert variable definitions
    struct Transfer {from: address, to: address, tokenId: U256}
    struct Approval {owner: address, approved: address, tokenId: U256}
    struct ApprovalForAll {owner: address, operator: address, approved: bool}

    resource struct State {
    owners: Table<U256, address>,
    balances: Table<address, U256>,
    tokenApprovals: Table<U256, address>,
    operatorApprovals: Table<address, Table<address, bool>>,
    }

    //Create transition
    fun create ( )
    {
        move_to<ERC721_res>(&sign(self()), ERC721_res {
            currState: b"Running"
        });

        //Actions
        move_to<State>(
            &sign(self()),
            State {
                owners: Table::empty<U256, address>(),
                balances: Table::empty<address, U256>(),
                tokenApprovals: Table::empty<U256, address>(),
                operatorApprovals: Table::empty<address, Table<address, bool>>(),
            }
        ); 
    }

    //Transitions
    fun approve ( approver: address, tokenId: U256)  
    acquires ERC721_res
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guard variable declarations
        let s = borrow_global_mut<State>(self());
        let owner = *( Table::borrow_mut_with_default(&mut s.owners, &tokenId, @0x0) );

        //Guards
        assert((owner != @0x0) && (approver != owner));
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        if(!Table::contains(&s.operatorApprovals, &owner)) {
            Table::insert(
                &mut s.operatorApprovals,
                &owner,
                Table::empty<address, bool>()
            )
        };
        let approvals = Table::borrow_mut(&mut s.operatorApprovals, &owner);
        let is_approved = *( Table::borrow_mut_with_default(approvals, &sender(), false) );

        let owned_or_approved: bool = sender() == owner || is_approved;
        assert(owned_or_approved);

        *( Table::borrow_mut_with_default(&mut s.tokenApprovals, &tokenId, @0x0) ) = approver;
        emit(Approval{owner: owner, approved: approved, tokenId: tokenId});
        
        //State change
        *baseResource.currState = b"Running";
        
    }
    
    fun balanceOf ( owner: address) : U256  
    acquires ERC721_res, State 
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert(owner != @0x0);
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let balance = *( Table::borrow_mut_with_default(&mut s.balances, &owner, U256::zero()) );
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return balance;
        
    }
    
    fun getApproved ( tokenId: U256) : address  
    acquires ERC721_res, State 
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert(owner != @0x0);
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let owner = *( Table::borrow_mut_with_default(&mut s.owners, &tokenId, @0x0) );
        let approved_address = *( Table::borrow_mut_with_default(&mut s.tokenApprovals, &tokenId, @0x0) );
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return approved_address;
    }
    
    fun isApprovedForAll ( owner: address, operator: address) : bool  
    acquires ERC721_res, State 
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        if(!Table::contains(&s.operatorApprovals, &owner)) {
            Table::insert(
                &mut s.operatorApprovals,
                &owner,
                Table::empty<address, bool>()
            )
        };
        let approvals = Table::borrow_mut(&mut s.operatorApprovals, &owner);
        let is_approved = *( Table::borrow_mut_with_default(approvals, &operator, false) );
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return is_approved; 
        
    }
    
    fun ownerOf ( tokenId: U256) : address  
    acquires ERC721_res, State 
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let owner = *( Table::borrow_mut_with_default(&mut s.owners, &tokenId, @0x0) );
         
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return owner;
        
    }
    
    fun setApprovalForAll ( operator: address, approved: bool)  
    acquires ERC721_res, State 
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert(sender() != operator);
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        if(!Table::contains(&s.operatorApprovals, &sender())) {
            Table::insert(&mut s.operatorApprovals, &sender(), Table::empty<address, bool>());
        }
        let approvals = Table::borrow_mut(&mut s.operatorApprovals, &sender());
        *( Table::borrow_mut_with_default(approvals, &operator, false) ) = approved;
        emit(ApprovalForAll{owner: sender(), operator: operator, approved: approved}); 
        
        //State change
        *baseResource.currState = b"Running";
        
    }
    
    fun transferFrom ( from: address, to: address, tokenId: U256)  
    acquires ERC721_res, State 
    {
        let baseResource = borrow_global_mut<ERC721_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guard variable declarations
        let s = borrow_global_mut<State>(self());
        let owner = *( Table::borrow_mut_with_default(&mut s.owners, &tokenId, @0x0) );

        // Guards
        assert((owner != @0x0) && (to != @0x0) && (owner == from));
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let approved_address = *( Table::borrow_mut_with_default(&mut s.tokenApprovals, &tokenId, @0x0) );
        if(!Table::contains(&s.operatorApprovals, &owner)) {
            Table::insert(&mut s.operatorApprovals, &owner, Table::empty<address, bool>());
        };
        let approvals = Table::borrow_mut(&mut s.operatorApprovals, &owner);
        let is_approved = *( Table::borrow_mut_with_default(approvals, &sender(), false) );

        let owned_approved_or_authorized: bool = sender() == owner || approved_address == sender() || is_approved;
        assert(owned_approved_or_authorized);
            
        *( Table::borrow_mut_with_default(&mut s.tokenApprovals, &tokenId, @0x0) ) = @0x0;
        emit(Approval{owner: owner, approved: @0x0, tokenId: tokenId});

        let mut_balance_from = mut_balanceOf(s, from);
        let mut_balance_to = mut_balanceOf(s, to);
        let mut_owner_token = mut_ownerOf(s, copy tokenId);
        *mut_balance_from = U256::sub(*mut_balance_from, U256::one());
        *mut_balance_to = U256::add(*mut_balance_to, U256::one());
        *mut_owner_token = to;
        
        //State change
        *baseResource.currState = b"Running";
        
    }

}