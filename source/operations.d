module operations;

import defs;

//
class Operations
{
    OperationStore store;
}


struct Op
{
    size_t opcode;
    size_t arg;
}


class OperationStore
{
    Op[] store;
    Op*  start;
    Op*  end;

    this()
    {
        store = new Op[](OP_STORE_SIZE);
    }


    bool empty()
    {
        return (start == end);
    }


    auto limit()
    {
        return store.ptr + store.length;
    }


    void put( Op op )
    {
        // check free space
        if ( 
            ( start < end ) && ( end < limit ) ||
            ( start > end ) && ( start - end > 0 )
           )
        {
            // yes free
        }

        //
        if ( start == end )
        {
            *end = op;
            end += 1;
        }
    }
}

// mode 1
// --------------------------
// ^
// start
// end

// mode 2
// ============--------------
// ^          ^
// start
//           end

// mode 3
// ==========================
// ^                        ^
// start
//                        end

// mode 4
// ====----------============
//    ^          ^           
//             start
//   end                    

// mode 5
// ==========================
//              ^^           
//               start
//            end                    

