require('@g-js-api/g.js');
const fs = require('fs');

$.exportConfig({
  type: 'savefile',
  options: { info: true }
}).then(x => {    

    const scode = fs.readFileSync("encoded_trace.json", "utf8");
    const code = JSON.parse(scode);

    $.add(object({
        OBJ_ID: 1,
        X: 105,
        Y: 75,
    }));
    
    $.add(object({
        OBJ_ID: 1268,
        X: 105,
        Y: 70,
        TARGET: group(9990),
        TOUCH_TRIGGERED: true,
    }));
    
    $.add(object({
        OBJ_ID: 1268,
        X: 165,
        Y: 75,
        TARGET: group(9990),
        SPAWN_DURATION: 0.005,
        SPAWN_TRIGGERED: true,
        MULTI_TRIGGER: true,
        GROUPS: group(9990),
    }));

    $.add(object({
        OBJ_ID: 3607,
        X: 225,
        Y: 75,
        SEQUENCE: code.map(y => y + '.1').join('.'),
        SPAWN_TRIGGERED: true,
        MULTI_TRIGGER: true,
        GROUPS: group(9990),
    }));
    

    const sinstructions = fs.readFileSync("unique_instructions.json", "utf8");
    const instructions = JSON.parse(sinstructions);
        
    for (let i = 0; i < instructions.length; i++){
        if(instructions[i][0] == "subl"){
            if(instructions[i][2] == "imm"){
                $.add(object({
                    OBJ_ID: 1817,
                    X: 105 + 30 * i,
                    Y: 135,
                    COUNT: -instructions[i][1],
                    ITEM: instructions[i][3],
                    SPAWN_TRIGGERED: true,
                    MULTI_TRIGGER: true,
                    GROUPS: group(i + 1),
                }))
            }
            else if (instructions[i][2] == "reg"){
                $.add(object({
                    OBJ_ID: 3619,
                    X: 105 + 30 * i,
                    Y: 135,
                    ITEM_ID_1: instructions[i][1],
                    TYPE_1: 1,
                    ITEM_TARGET: instructions[i][3],
                    ITEM_TARGET_TYPE: 1,
                    MOD: 1,
                    ASSIGN_OP: 3,
                    SPAWN_TRIGGERED: true,
                    MULTI_TRIGGER: true,
                    GROUPS: group(i + 1),
                }))
            }
        }
        else if(instructions[i][0] == "addl"){
            if(instructions[i][2] == "imm"){
                $.add(object({
                    OBJ_ID: 1817,
                    X: 105 + 30 * i,
                    Y: 135,
                    COUNT: instructions[i][1],
                    ITEM: instructions[i][3],
                    SPAWN_TRIGGERED: true,
                    MULTI_TRIGGER: true,
                    GROUPS: group(i + 1),
                })) 
            }
            else if (instructions[i][2] == "reg"){
                $.add(object({
                    OBJ_ID: 3619,
                    X: 105 + 30 * i,
                    Y: 135,
                    ITEM_ID_1: instructions[i][1],
                    TYPE_1: 1,
                    ITEM_TARGET: instructions[i][3],
                    ITEM_TARGET_TYPE: 1,
                    MOD: 1,
                    ASSIGN_OP: 2,
                    SPAWN_TRIGGERED: true,
                    MULTI_TRIGGER: true,
                    GROUPS: group(i + 1),
                }))
            }
        }
        else if(instructions[i][0] == "movl"){
            if(instructions[i][2] == "imm"){
                $.add(object({
                    OBJ_ID: 1817,
                    X: 105 + 30 * i,
                    Y: 135,
                    COUNT: instructions[i][1],
                    ITEM: instructions[i][3],
                    OVERRIDE_COUNT: true,
                    SPAWN_TRIGGERED: true,
                    MULTI_TRIGGER: true,
                    GROUPS: group(i + 1),
                }))
            }
            else if (instructions[i][2] == "reg"){
                $.add(object({
                    OBJ_ID: 3619,
                    X: 105 + 30 * i,
                    Y: 135,
                    ITEM_ID_1: instructions[i][1],
                    TYPE_1: 1,
                    ITEM_TARGET: instructions[i][3],
                    ITEM_TARGET_TYPE: 1,
                    MOD: 1,
                    SPAWN_TRIGGERED: true,
                    MULTI_TRIGGER: true,
                    GROUPS: group(i + 1),
                }))
            }
        }
        else if(instructions[i][0] == "idivl"){
            $.add(object({
                OBJ_ID: 3619,
                X: 105 + 30 * i,
                Y: 135,
                ITEM_ID_1: 9500,
                TYPE_1: 1,
                ITEM_ID_2: instructions[i][1],
                TYPE_2: 1,
                ITEM_TARGET: 9505,
                ITEM_TARGET_TYPE: 1,
                MOD: 1,
                OP_1: 4,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(i + 1),
            }))
            $.add(object({
                OBJ_ID: 3619,
                X: 106 + 30 * i,
                Y: 165,
                ITEM_ID_1: instructions[i][1],
                TYPE_1: 1,
                ITEM_ID_2: 9505,
                TYPE_2: 1,
                ITEM_TARGET: 9503,
                ITEM_TARGET_TYPE: 1,
                MOD: 1,
                OP_1: 3,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(i + 1),
            }))
            $.add(object({
                OBJ_ID: 3619,
                X: 107 + 30 * i,
                Y: 195,
                ITEM_ID_1: 9500,
                TYPE_1: 1,
                ITEM_ID_2: 9503,
                TYPE_2: 1,
                ITEM_TARGET: 9503,
                ITEM_TARGET_TYPE: 1,
                MOD: 1,
                OP_1: 2,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(i + 1),
            }))
            $.add(object({
                OBJ_ID: 3619,
                X: 108 + 30 * i,
                Y: 225,
                ITEM_ID_1: 9505,
                TYPE_1: 1,
                ITEM_TARGET: 9500,
                ITEM_TARGET_TYPE: 1,
                MOD: 1,            
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(i + 1),
            }))
        }
        else if(instructions[i][0] == "stop"){
            $.add(object({
                OBJ_ID: 1616,
                X: 105 + 30 * i,
                Y: 135,
                TARGET: group(9990),
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(i + 1),
            }))
            $.add(object({
                OBJ_ID: 3600,
                X: 106 + 30 * i,
                Y: 165,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(i + 1),
            }))
        }
    }
});
