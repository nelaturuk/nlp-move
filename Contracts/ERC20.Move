module Evm::ERC20 {

    //Imports
    use Evm::Evm::{sender, self, sign, emit};
    use Evm::Table::{Self, Table};
    use Evm::U256::{Self, U256};

    //Base Resource
    resource struct ERC20_res {
        currState : vector<u8>
    }

    //Insert variable definitions
    struct Approval {owner: address, spender: address, value: U256}
    struct Transfer {from: address, to: address, value: U256}

    resource struct State {
        balances: Table<address, U256>,
        allowances: Table<address, Table<address, U256>>,
        total_supply: U256,
    }

    //Create transition
    fun create ( ) 
    acquires State 
    {
        move_to<ERC20_res>(&sign(self()), ERC20_res {
            currState: b"Running"
        });

        //Actions
        move_to<State>(
            &sign(self()),
            State {
                total_supply: U256::zero(),
                balances: Table::empty<address, U256>(),
                allowances: Table::empty<address, Table<address, U256>>(),
            }
        );

        let s = borrow_global_mut<State>(self());
        s.total_supply = U256::add(s.total_supply, initial_supply);
        let mut_bal_account = mut_balanceOf(s, sender());
        *mut_bal_account = U256::add(*mut_bal_account, initial_supply);
        emit(Transfer{from: @0x0, to: sender(), value: initial_supply});
    }

    //Transitions
    fun allowance ( owner: address, spender: address)  
    acquires ERC20_res
    {
        let baseResource = borrow_global_mut<ERC20_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        if(!Table::contains(&s.allowances, &owner)) {
            Table::insert(&mut s.allowances, &owner, Table::empty<address, U256>())
        };
        let allowance_owner = Table::borrow_mut(&mut s.allowances, &owner);
        let remaining = Table::borrow_mut_with_default(allowance_owner, &spender, U256::zero())

        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return *remaining; 
        
    }
    
    fun approve ( spender: address, amount: U256) : bool  
    acquires ERC20_res, State 
    {
        let baseResource = borrow_global_mut<ERC20_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert((sender() != @0x0) && (spender != @0x0));
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        if(!Table::contains(&s.allowances, &sender())) {
        Table::insert(&mut s.allowances, &sender(), Table::empty<address, U256>())
        };
        let allowance_owner = Table::borrow_mut(&mut s.allowances, &sender());
        Table::insert(allowance_owner, &spender, copy amount);
        emit(Approval{owner: sender(), spender: spender, value: amount});
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return true;
    }
    
    fun balanceOf ( to: address, amount: U256) : bool  
    acquires ERC20_res, State 
    {
        let baseResource = borrow_global_mut<ERC20_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert(sender() != to);
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let balance = *Table::borrow_mut_with_default(&mut s.balances, &owner, U256::zero());
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return balance;
    }
    
    fun totalSupply ( ) : U256  
    acquires ERC20_res, State, State2, State3, State4 
    {
        let baseResource = borrow_global_mut<ERC20_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return s.total_supply;
        
    }
    
    fun transfer ( to: address, amount: U256) : bool  
    acquires ERC20_res
    {
        let baseResource = borrow_global_mut<ERC20_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert(to != @0x0);
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let mut_balance_sender = *Table::borrow_mut_with_default(&mut s.balances, &sender(), U256::zero());
        let mut_balance_to = *Table::borrow_mut_with_default(&mut s.balances, &to, U256::zero());

        assert(U256::ge(*mut_balance_sender, copy amount));

        *mut_balance_sender = U256::sub(*mut_balance_sender, copy amount);
        *mut_balance_to = U256::add(*mut_balance_to, copy amount);
        emit(Transfer{from: sender(), to: to, value: amount});
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return true;
    }
    
    fun transferFrom ( from: address, to: address, amount: U256) : bool  
    acquires ERC20_res, State 
    {
        let baseResource = borrow_global_mut<ERC20_res>(self());
        assert(*baseResource.currState == b"Running");
        
        //Guards
        assert((from != @0x0) && (to != @0x0));
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        if(!Table::contains(&s.allowances, &from)) {
            Table::insert(&mut s.allowances, &from, Table::empty<address, U256>())
        };
        let allowance_owner = Table::borrow_mut(&mut s.allowances, &from);
        let allowance_for_sender = Table::borrow_mut_with_default(allowance_owner, &sender(), U256::zero());
        let mut_balance_from = *Table::borrow_mut_with_default(&mut s.balances, &from, U256::zero());
        let mut_balance_to = *Table::borrow_mut_with_default(&mut s.balances, &to, U256::zero());

        assert(U256::ge(*allowance_for_sender, copy amount));
        assert(U256::ge(*mut_balance_from, copy amount));

        *mut_balance_from = U256::sub(*mut_balance_from, copy amount);
        *allowance_for_sender = U256::sub(*allowance_for_sender, copy amount);
        *mut_balance_to = U256::add(*mut_balance_to, copy amount);
        emit(Transfer{from: from, to: to, value: amount});
        
        //State change
        *baseResource.currState = b"Running";

        //Return statement
        return true; 
        
    }

}