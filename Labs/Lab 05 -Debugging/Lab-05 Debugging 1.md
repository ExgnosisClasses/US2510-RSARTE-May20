# Lab 05: Debugging One

This is a very short lab where you fix the compiler errors from the previous lab.

## Step 1: The Receiver error

###
There is an error in the `Receiver.cpp` file.

```console
"..\Receiver.cpp(27): error C2065: 'message': undeclared identifier"
```

Looking at the line:

```text
logPort.log("Received Message: " + message);
```
The problem is that the compiler doesn't recognize the message variable. 
- The Reciver is receiving a sayHello(message : RTString) event, but RSARTE doesn't expose the parameter directly as message in the transition effect.
- Instead, RSARTE wraps the event parameter in an object representing the trigger, and you must extract the parameter from the trigger using the reference `rtdata`.
- The `rtdata` refrence is untypes, so you have to cast it to an RTString type, then dereference to get the string.
- Plus, we can't use the `+` operator in this context
- The easiest solution is to just make two log entries like this

```text
logPort.log("Receiver: ");
logPort.log(*(RTString*)rtdata);
```

Make the change and rebuild.

Recap 
- rtdata is an auto-generated void* pointer passed to the transition effect
- RSARTE expects the code to cast it to the correct type (matching the protocol parameter)
- In this case, sayHello(message: RTString) means: rtdata is a pointer to an RTString object

## Step 2: Sender Error

Now that the Receiver compiles correctly, there is another error

```console
.\Sender.cpp(45): error C2664: 'RTOutSignal HelloWorld::Conjugate::sayHello(const RTTypedValue_RTString &)': cannot convert argument 1 from 'const char [13]' to 'const RTTypedValue_RTString &'
..\Sender.cpp(45): note: Reason: cannot convert from 'const char [13]' to 'const RTTypedValue_RTString'
..\Sender.cpp(45): note: No constructor could take the source type, or constructor overload resolution was ambiguous
```

For this line:

```text
 sndPort.sayHello("Hello World!").send();
```

The issue here is exactly the same as before. The error

```text
cannot convert from 'const char [13]' to 'const RTTypedValue_RTString'
```

This means that RSARTE expects an argument of type:
- `const RTTypedValue_RTString&`
- But it is being passed a C-style string literal ("Hello World!"), which can't be implicitly converted.

To fix that issue, use this action code instead:

```text
sndPort.sayHello(RTTypedValue_RTString("Hello World!")).send();
```

- `RTTypedValue_RTString` is a wrapper that RSARTE’s signal system uses to pass structured data with type safety
- The protocol sayHello(message: RTString) expects this as the payload
- RSARTE generates the `.sayHello()` method signature to require a `RTTypedValue_RTString`, not a raw `RTString` or` const char*`

## Step 3: Build and Run

The app should compile without problem

Run it as we did before in other labs and we should the following output

```console
targetRTS: observability listening not enabled

RTS debug: ->quit
  Task 0 detached
Receiver:
Hello World!
```