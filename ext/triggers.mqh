#include <Arrays\ArrayObj.mqh>
#include "../objecttools.mqh"
#include "../arraytools.mqh"

#define __TRIGGER_MANAGER_ARR_INCREASE 16

//TODO: Deregister based on object id:
// triggermanager(deregister(trigger))

// TODO: Find based on class id

// These requires generating a class ID and an object ID

template<typename T>
class CTriggerCallback {
public:
    CUSTOMNAME
    OBJECTID
    CLASSNAME
    virtual void Callback(T& out) {
        ABSTRACT_METHOD_WARNING
    }
};

template<typename T>
class CTriggerCallbackWrap: public CTriggerCallback<T> {
    CTrigger<T>* m_trigger;
public:
    CLASSNAME
    OBJECTID_DELEGATE(m_trigger)
    CTriggerCallbackWrap(CTrigger<T>* trigger): m_trigger(trigger) {}
    virtual void Callback(T& out) {
        m_trigger.RunConnected(out);
    }
};

template<typename TIn, typename TOut>
class CTriggerCallbackWrapConnected: public CTriggerCallback<TIn> {
    CTriggerConnected<TIn,TOut>* m_trigger;
public:
    CLASSNAME
    OBJECTID_DELEGATE(m_trigger)
    CTriggerCallbackWrapConnected(CTriggerConnected<TIn,TOut>* trigger): m_trigger(trigger) {}
    virtual void Callback(TIn& in) {
        m_trigger.RunConnected(in);
    }
};


class CTriggerBase {
public:
    CUSTOMNAME
    OBJECTID
    CLASSNAME
public:
    virtual void Run() {
        ABSTRACT_METHOD_WARNING
    }
};

template<typename T>
class CTrigger : public CTriggerBase {
protected:
    CTriggerCallback<T>* m_arr[];
public:
    CLASSNAME
    void AddCallback(CTriggerCallback<T>* cb) {
        int newsize = ArraySize(m_arr)+1;
        int reserve = newsize;
        int excess = newsize%__TRIGGER_MANAGER_ARR_INCREASE;
        if (excess > 0) reserve += __TRIGGER_MANAGER_ARR_INCREASE;
        ArrayResize(m_arr,newsize,reserve);
        m_arr[newsize-1] = cb;
    }
    void RemoveCallback(CTriggerCallback<T>* cb) {
        int size = ArraySize(m_arr);
        for (int i = 0; i != size; i++) {
            if (GetObjectId(m_arr[i]) == GetObjectId(cb)) {
                ArrayRemoveItem(m_arr,i,__TRIGGER_MANAGER_ARR_INCREASE);
            }
        }
    }
    void Connect(CTrigger<T>* other) {
        this.AddCallback(new CTriggerCallbackWrap<T>(other));
    }
    template<typename TOut>
    void Connect(CTriggerConnected<T,TOut>* other) {
        this.AddCallback(new CTriggerCallbackWrapConnected<T,TOut>(other));
    }
    template<typename T1>
    void Disconnect(CTrigger<T1>* other) {
        int size = ArraySize(m_arr);
        for (int i = 0; i != size; i++) {
            if (GetObjectId(m_arr[i]) == GetObjectId(other)) {
                ArrayRemoveItem(m_arr,i,__TRIGGER_MANAGER_ARR_INCREASE);
            }
        }
    }
    void Run() {
        T out;
        if (Trigger(out)) {
            RunTrigger(out);
        }
    }
    void RunConnected(T& out) {
        //Print("RunConnected: "+this.GetClassName());
        if (Trigger(out)) {
            RunTrigger(out);
        }
    }
    void RunTrigger(T& out) {
        int size = ArraySize(m_arr);
        for (int i = 0; i < size; i++) {
            CTriggerCallback<T>* cb = m_arr[i];
            cb.Callback(out);
        }
    }
    virtual bool Trigger(T& out) {
        ABSTRACT_METHOD_WARNING
        return false;
    }
};

template<typename TIn, typename TOut>
class CTriggerConnected : public CTrigger<TOut> {
public:
    CLASSNAME
    void RunConnected(TIn& in) {
        TOut out;
        if (Trigger(in, out)) {
            int size = ArraySize(m_arr);
            for (int i = 0; i < size; i++) {
                CTriggerCallback<TOut>* cb = m_arr[i];
                cb.Callback(out);
            }
        }
    }
    
    virtual bool Trigger(TIn& in, TOut& out) {
        ABSTRACT_METHOD_WARNING
        return false;
    }
};


class CTriggerManager {
    CTriggerBase* m_arr[];
public:
    CTriggerManager() {
        
    }
    template<typename T>
    void Register(CTrigger<T>* trigger) {
        int newsize = ArraySize(m_arr)+1;
        int reserve = newsize;
        int excess = newsize%__TRIGGER_MANAGER_ARR_INCREASE;
        if (excess > 0) reserve += __TRIGGER_MANAGER_ARR_INCREASE;
        ArrayResize(m_arr,newsize,reserve);
        m_arr[newsize-1] = trigger;
    }
    template<typename T>
    void Unregister(CTrigger<T>* trigger) {
        int size = ArraySize(m_arr);
        for (int i = 0; i != size; i++) {
            if (GetObjectId(m_arr[i]) == GetObjectId(trigger)) {
                ArrayRemoveItem(m_arr,i,__TRIGGER_MANAGER_ARR_INCREASE);
                return;
            }
        }
    }
    void Run() {
        int size = ArraySize(m_arr);
        for (int i = 0; i < size; i++) {
            CTriggerBase* trigger = m_arr[i];
            trigger.Run();
        }
    }
};

#define TRIGGER_CALLBACK_TYPE(TYPE,FUNC_TYPE,CLASS_NAME) typedef void (*FUNC_TYPE)(TYPE& out); class CLASS_NAME : public CTriggerCallback<TYPE> {    FUNC_TYPE m_func;public:    CLASSNAME CLASS_NAME(FUNC_TYPE func): m_func(func) {}    virtual void Callback(TYPE& out) {        m_func(out);    }};CTriggerCallback<TYPE>* GetCallback(FUNC_TYPE func) {    return new CLASS_NAME(func);}

/*
typedef void (*FUNC_TYPE)(TYPE& out);
class CLASS_NAME : public CTriggerCallback<TYPE> {
    FUNC_TYPE m_func;
public:
    CLASSNAME
    CLASS_NAME(FUNC_TYPE func): m_func(func) {}
    virtual void Callback(TYPE& out) {
        m_func(out);
    }
};
CTriggerCallback<TYPE>* GetCallback(FUNC_TYPE func) {
    return new CLASS_NAME(func);
}
*/


#define TRIGGER_TYPE(TYPE,FUNC_TYPE,CLASS_NAME) typedef bool (*FUNC_TYPE)(TYPE& out);class CLASS_NAME : public CTrigger<TYPE> {    FUNC_TYPE m_func;public:    CLASS_NAME(FUNC_TYPE func): m_func(func) {}    bool Trigger(TYPE& out) {        return m_func(out);    }};CTrigger<TYPE>* GetTrigger(FUNC_TYPE func) {    return new CLASS_NAME(func);}
#define TRIGGER_TYPE_(TYPE,FUNC_TYPE,CLASS_NAME,CONVF_NAME) typedef bool (*FUNC_TYPE)(TYPE& out);class CLASS_NAME : public CTrigger<TYPE> {    FUNC_TYPE m_func;public:    CLASSNAME CLASS_NAME(FUNC_TYPE func): m_func(func) {}    bool Trigger(TYPE& out) {        return m_func(out);    }};CTrigger<TYPE>* CONVF_NAME(FUNC_TYPE func) {    return new CLASS_NAME(func);}
/*
typedef bool (*FUNC_TYPE)(TYPE& out);
class CLASS_NAME : public CTrigger<TYPE> {
    FUNC_TYPE m_func;
public:
    CLASSNAME
    CLASS_NAME(FUNC_TYPE func): m_func(func) {}
    bool Trigger(TYPE& out) {
        return m_func(out);
    }
};
CTrigger<TYPE>* GetTrigger(FUNC_TYPE func) {
    return new CLASS_NAME(func);
}
*/


#define TRIGGER_CONNECTED_TYPE(TYPEIN,TYPEOUT,FUNC_TYPE,CLASS_NAME) typedef bool (*FUNC_TYPE)(TYPEIN& in, TYPEOUT& out);class CLASS_NAME : public CTriggerConnected<TYPEIN,TYPEOUT> {    FUNC_TYPE m_func;public:    CLASSNAME CLASS_NAME(FUNC_TYPE func): m_func(func) {}    bool Trigger(TYPEIN& in, TYPEOUT& out) {        return m_func(in,out);    }};CTriggerConnected<TYPEIN,TYPEOUT>* GetTrigger(FUNC_TYPE func) {    return new CLASS_NAME(func);}
/*
typedef bool (*FUNC_TYPE)(TYPEIN& in, TYPEOUT& out);
class CLASS_NAME : public CTriggerConnected<TYPEIN,TYPEOUT> {
    FUNC_TYPE m_func;
public:
    CLASSNAME
    CLASS_NAME(FUNC_TYPE func): m_func(func) {}
    bool Trigger(TYPEIN& in, TYPEOUT& out) {
        return m_func(in,out);
    }
};
CTriggerConnected<TYPEIN,TYPEOUT>* GetTrigger(FUNC_TYPE func) {
    return new CLASS_NAME(func);
}
*/