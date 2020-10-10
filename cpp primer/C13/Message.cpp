#include <string>
#include <set>

class Folder;
class Message {
    friend class Folder;
    public:
        // folders is implicitly initialized to the empty set
        explicit Message(const std::string &str = ""):
                    contents(str) { }
        // copy control to manage pointers to this Message
        Message(const Message&); // copy constructor
        Message& operator=(const Message&); // copy assignment
        Message(Message &&);
        Message& operator=(Message&&);
        ~Message(); // destructor
        // add/remove this Message from the specified Folder's set of messages
        void save(Folder&);
        void remove(Folder&);
    private:
        std::string contents; // actual message text
        std::set<Folder*> folders; // Folders that have this Message
        // utility functions used by copy constructor, assignment, and destructor
        // add this Message to the Folders that point to the parameter
        void add_to_Folders(const Message&);
        // remove this Message from every Folder in folders
        void remove_from_Folders();
        void move_Folders(Message*);
};

void Message::save(Folder &f)
{
    folders.insert(&f); // add the given Folder to our list of Folders
    f.addMsg(this); // add this Message to f's set of Messages
}

void Message::remove(Folder &f)
{
    folders.erase(&f); // take the given Folder out of our list of Folders
    f.remMsg(this); // remove this Message to f's set of Messages
}

// add this Message to Folders that point to m
void Message::add_to_Folders(const Message &m)
{
    for (auto f : m.folders) // for each Folder that holds m
        f->addMsg(this); // add a pointer to this Message to that Folder
}

Message::Message(const Message &m):
    contents(m.contents), folders(m.folders)
{
    add_to_Folders(m); // add this Message to the Folders that point to m
}

// remove this Message from the corresponding Folders
void Message::remove_from_Folders()
{
    for (auto f : folders) // for each pointer in folders
        f->remMsg(this); // remove this Message from that Folder
}

Message::~Message()
{
    remove_from_Folders();
}

Message& Message::operator=(const Message &rhs)
{
    // handle self-assignment by removing pointers before inserting them
    remove_from_Folders(); // update existing Folders
    contents = rhs.contents; // copy message contents from rhs
    folders = rhs.folders; // copy Folder pointers from rhs
    add_to_Folders(rhs); // add this Message to those Folders
    return *this;
}

void swap(Message &lhs, Message &rhs)
{
    using std::swap; // not strictly needed in this case, but good habit
    // remove pointers to each Message from their (original) respective Folders
    for (auto f: lhs.folders)
        f->remMsg(&lhs);
    for (auto f: rhs.folders)
        f->remMsg(&rhs);
    // swap the contents and Folder pointer sets
    swap(lhs.folders, rhs.folders); // uses swap(set&, set&)
    swap(lhs.contents, rhs.contents); // swap(string&, string&)
    // add pointers to each Message to their (new) respective Folders
    for (auto f: lhs.folders)
        f->addMsg(&lhs);
    for (auto f: rhs.folders)
        f->addMsg(&rhs);
}

class Folder{
    public:
        Folder() = default;
        Folder(const Folder&);
        Folder& operator=(const Folder&);
        void addMsg(Message*);
        void remMsg(Message*);
        ~Folder();
    private:
        std::set<Message*> msgs;   
};

void Folder::addMsg(Message* msg){
    msgs.insert(msg);
}

void Folder::remMsg(Message* msg){
    msgs.erase(msg);
}

void Message::move_Folders(Message *m)
{
    folders = std::move(m->folders);
    for(auto f:folders){
        f->remMsg(m);
        f->addMsg(this);
    }
    m->folders.clear();
}

Message::Message(Message &&msg):contents(std::move(msg.contents)){
    move_Folders(&msg);
}

Message& Message::operator=(Message &&msg){
    if(this != &msg){
        remove_from_Folders();
        contents = std::move(msg.contents);
        move_Folders(&msg);
    }
    return *this;
}
