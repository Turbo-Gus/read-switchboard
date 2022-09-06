
module read_oracle::Oracle{
    use std::signer;
    use switchboard::aggregator;
    use switchboard::math::{Self};

// store latest value
struct AggregatorInfo has copy, drop, store, key {
    aggregator_addr: address,
    latest_result: u128,
    latest_result_scaling_factor: u8,
    latest_result_neg: bool,
}

// get latest value
public fun save_latest_value(user: &signer, aggregator_addr: address) {
    // get latest value
    let latest_value = aggregator::latest_value(aggregator_addr);
    let (value, scaling_factor, neg) = math::unpack(latest_value);

    std::debug::print(&value);
    std::debug::print(&scaling_factor);
    std::debug::print(&neg);

    move_to(user, AggregatorInfo {
        aggregator_addr: aggregator_addr,
        latest_result: value,
        latest_result_scaling_factor: scaling_factor,
        latest_result_neg: neg,
    });
}

    // some testing that uses aggregator test utility functions
    #[test(oracle = @0x1, user = @0xABC)]
    public entry fun test_aggregator(oracle: &signer, user: &signer) {

        // creates test aggregator with data
        aggregator::new_test(oracle, 100, 0, false);
        
        aptos_framework::account::create_account_for_test(signer::address_of(user));

        // print out value
        std::debug::print(&aggregator::latest_value(signer::address_of(oracle)));

        save_latest_value(user, signer::address_of(oracle));
    }
}
