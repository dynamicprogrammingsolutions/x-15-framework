
int __GetClassId() {
    static int nextid = 0;
    return nextid++;
}

int __GetObjectId() {
    static int nextid = 0;
    return nextid++;
}

template<typename T>
string __GetClassName(T* clazz) {
    return typename(T);
}

template<typename T>
string GetClassName(T* obj) {
    return obj.GetClassName();
}

template<typename T>
int GetObjectId(T* obj) {
    return obj.GetObjectId();
}

template<typename T>
bool InstanceOf(void* obj) {
   T* casted_obj = dynamic_cast<T*>(obj);
   return casted_obj != NULL;
}

#define CUSTOMNAME private:    string __customname;public:    void SetName(string name) {        __customname = name;    }    string GetName() {        return __customname;    }
/*
private:
    string __customname;
public:
    void SetName(string name) {
        __customname = name;
    }
    string GetName() {
        return __customname;
    }
*/

#define CLASSNAME public:    virtual string GetClassName() {        return __GetClassName(GetPointer(this));    }
/*
#define CLASSNAME
public:
    virtual string GetClassName() {
        return __GetClassName(this);
    }

#define CLASSID private:    static int __GetClassId() {        static int id = -1;        if (id == -1) id = __GetClassId();        return id;    }public:    virtual int GetClassId() {        this::__GetClassId();    }

/*
#define CLASSID
private:
    static int __GetClassId() {
        static int id = -1;
        if (id == -1) id = __GetClassId();
        return id;
    }
public:
    virtual int GetClassId() {
        this::__GetClassId();
    }
*/

#define OBJECTID virtual int GetObjectId() {    static int id = -1;    if (id == -1) id = __GetObjectId();    return id;}

/*
#define OBJECTID
virtual int GetObjectId() {
    static int id = -1;
    if (id == -1) id = __GetObjectId();
    return id;
}

*/

#define OBJECTID_DELEGATE(DELEGATE) virtual int GetObjectId() {    static int id = -1;    if (id == -1) id = __GetObjectId();    return id;}

/*
#define OBJECTID_DELEGATE(DELEGATE)
virtual int GetObjectId() {
    return DELEGATE.GetObjectId();
}
*/

#define ABSTRACT_METHOD_WARNING Print("Calling abstract method in ",__FUNCTION__," class ",this.GetClassName());
/*
    Print("Calling abstract method in ",__FUNCTION__," class ",this.GetClassName());
*/