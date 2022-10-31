import { strict as assert } from 'node:assert';
import { TestFn } from "spec/helper";

export const check_if_2_plus_2_eqls_5: TestFn = {
        description : "should check if something 2 + 2 is 5",
        execute: () => {
            assert.strictEqual(2 + 2, 5, "O Noes! What dis! This wasn't expected at all :(")
        }
}

export const check_if_1_eqls_1 = {
    description: "should check if something is true",
    execute: () => {
        assert.strictEqual(1, 1)
    }
}
