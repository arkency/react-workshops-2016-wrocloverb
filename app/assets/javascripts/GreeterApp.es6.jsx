const { React, 
        ReactDOM, 
        Redux, 
        ReactRedux, 
        $ } = window;

const { Panel } = ReactBootstrap;

function GreeterApp () {
  const initialState = () => {
    return { name: "workshop attendands" };
  };

  const changeName = (name) => {
    return {
      type: "CHANGE_NAME",
      name
    };
  };

  const update = (state = initialState(), action) => {
    switch (action.type) {
      case "CHANGE_NAME":
        return { name: action.name };
      default:
        return state;
    }
  };

  let store = Redux.createStore(update, initialState());

  const GreeterShow = ({name}) => {
    return <p>Hello, {name}!</p>;
  };

  const GreeterEditor = ({name, nameChanged}) => {
    return <input type='text'
                  value={name}
                  onChange={nameChanged} />;
  };

  const Greeter = ({name, nameChanged}) => {
    return (<div>
             <GreeterShow name={name} />
             <GreeterEditor name={name}
                            nameChanged={nameChanged}/>
           </div>);
  };

  const stateMapper = ({ name }) => { return { name }; };
  const dispatchMapper = (dispatch) => {
    return {
      nameChanged (event) {
        dispatch(changeName(event.target.value));
      }
    };
  };

  const connector = ReactRedux.connect(stateMapper, dispatchMapper);
  const ConnectedGreeter = connector(Greeter);

  return {
    ui () {
      return (<ReactRedux.Provider store={store}>
                <ConnectedGreeter />
              </ReactRedux.Provider>);
    }
  };
}
