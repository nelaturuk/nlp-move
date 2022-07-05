module Evm::blindAuction {

    //Imports
    use Evm::Evm::{sender, value, self, sign, emit, transfer, block_timestamp, keccak256};
    use Evm::Table::{Self, Table};
    use Evm::U256::{Self, U256};
    use std::vector;

    //Base Resource
    resource struct blindAuction_res {
        currState : vector<u8>
    }

    //Insert variable definitions
    resource struct Bid {
        blinded_bid: vector<u8>,
        deposit: U256,
    }

    resource struct State {
        bids: Table<address, vector<Bid>>, 
        pending_returns: Table<address, U256>,
        highest_bidder: address,
        highest_bid: U256,
    }

    resource struct Time {
        creation_time: U256,
        days: U256,
    }

    //Create transition
    fun create ( )
    {
        move_to<blindAuction_res>(&sign(self()), blindAuction_res {
            currState: b"ABB"
        });
        
        //Actions
        move_to<State>(
            &sign(self()),
            State {
                bids: Table::empty<address, vector<Bid>>(), 
                pending_returns: Table::empty<address, U256>(),
                highest_bidder: @0x0,
                highest_bid: 0,
                creation_time: block_timestamp()
            }
        );   
    }

    //Transitions
    fun bid ( blinded_bid: vector<u8>)
    acquires blindAuction_res, State 
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"ABB");

        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let mut_bid_vector = Table::borrow_mut_with_default(&mut s.bids, &sender(), vector::empty<Bid>());
        let bid = Bid<Currency> {blinded_bid: blinded_bid, deposit: value()};
        vector::push_back(&mut_bid_vector, bid);
        let mut_amount = Table::borrow_mut_with_default(&mut s.pending_returns, &sender(), U256::zero());
        *mut_amount = U256::add(*mut_amount, copy value()); 
        
        //State change
        *baseResource.currState = b"ABB";
    }
    
    fun cancelABB ( )  
    acquires blindAuction_res
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"ABB");
        
        //State change
        *baseResource.currState = b"C";   
    }
    
    fun cancelRB ( )  
    acquires blindAuction_res
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"RB");
        
        //State change
        *baseResource.currState = b"C";
    }
    
    fun close ( )  
    acquires blindAuction_res, Time 
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"ABB");
        
        //Guard variable declarations
        let t = borrow_global_mut<Time>(self()); 

        //Guards
        assert(block_timestamp() > t.creation_time + U256::mul(5, t.days));
        
        //State change
        *baseResource.currState = b"RB";
    }
    
    fun finish ( )  
    acquires blindAuction_res, Time 
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"RB");
        
        //Guard variable declarations
        let t = borrow_global_mut<Time>(self()); 

        //Guards
        assert(block_timestamp() > t.creation_time + U256::mul(10, t.days));

        //State change
        *baseResource.currState = b"InTransition";
        
        //State change
        *baseResource.currState = b"F";
    }
    
    fun reveal ( values: vector<U256>, secrets: vector<vector<u8>>)  
    acquires blindAuction_res, State 
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"RB");
        
        //Guards
        assert(vector::length(&values) == vector::length(&secrets));
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let mut_bid_vector = Table::borrow_mut_with_default(&mut s.bids, &sender(), vector::empty<Bid>());
        
        let length = vector::length(&mut_bid_vector);
        if (vector::length(&values) < length){
            length = vector::length(&values);
        }

        let i: u64 = 0;
        while (i < length) {
            let bid = *vector::borrow_mut(&mut_bid_vector, i);
            let value = *vector::borrow_mut(&mut values, i);
            let secret = *vector::borrow_mut(&mut secrets, i);

            if (bid.blindedBid == keccak256(value, secret) && U256::ge(bid.deposit, value) && U256::gt(value, s.highest_bid)) {
                s.highest_bid = value;
                s.highest_bidder = sender();
                
            }
            
            i += 1;
        } 

        //State change
        *baseResource.currState = b"RB";
    }
    
    fun unbid ( )  
    acquires blindAuction_res
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"C");
        
        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let mut_amount = Table::borrow_mut_with_default(&mut s.pending_returns, &sender(), U256::zero());
        if (*mut_amount > U256::zero()) {
            transfer(sender(), *mut_amount);
            *mut_amount = U256::zero();
        } 
        
        //State change
        *baseResource.currState = b"C"; 
    }
    
    fun withdraw ( )  
    acquires blindAuction_res, State 
    {
        let baseResource = borrow_global_mut<blindAuction_res>(self());
        assert(*baseResource.currState == b"F");

        //State change
        *baseResource.currState = b"InTransition";

        //Actions
        let s = borrow_global_mut<State>(self());
        let mut_amount = Table::borrow_mut_with_default(&mut s.pending_returns, &sender(), U256::zero());
        if (*mut_amount > U256::zero()) {
            if (sender() != sa.highest_bidder ) {
                transfer(sender(), *mut_amount);
            } else {
                transfer(sender(), U256::sub(*mut_amount, copy s.highest_bid));
            }
            *mut_amount = U256::zero();
        } 
        
        //State change
        *baseResource.currState = b"F"; 
    }

}