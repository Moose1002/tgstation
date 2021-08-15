import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, LabeledList, Section, Stack, Tabs, Table, TextArea } from '../components';
import { Window } from '../layouts';

export const RequestsConsole = (props, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', "messages");
  return (
    <Window
      width={600}
      height={500}>
      <Window.Content scrollable>
        <Section fitted>
          <Tabs>
              <Tabs.Tab
                selected={tab === "messages"}
                onClick={() => setTab("messages")}>
                Messages
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "request"}
                onClick={() => setTab("request")}>
                Request
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "emergency"}
                onClick={() => setTab("emergency")}>
                Emergencies
              </Tabs.Tab>
          </Tabs>
          </Section>
          {tab === "messages" && (
            <RequestsConsoleMessage />
          )}
          {tab === "request" && (
            <RequestsConsoleRequest />
          )}
          {tab === "emergency" && (
            <RequestsConsoleEmergencies />
          )}
      </Window.Content>
    </Window>
  );
};

export const RequestsConsoleMessageList = (props, context) => {
  const { act, data } = useBackend(context);
  const messages = data.messages || [];
  return (
  <Section
    title="Messages"
    buttons={
      <Button
        icon={data.silent ? 'volume-mute' : 'volume-up'}
        selected={!data.silent}
        onClick={() => act('silence')}/>
    }>
    {messages.length === 0 && (
        <Box color="good">
          No Messages
        </Box>
      )}
    {messages.length > 0 && (
      <Table>
        {messages.map(message => (
          <Table.Row
            key={message.source}
            className="candystripe">
            <Table.Cell>
              From: {message.source}
            </Table.Cell>
            <Table.Cell>
              Received: {message.creation_time}
            </Table.Cell>
            <Table.Cell textAlign="right">
              <Button
                icon="envelope"
                onClick={() => act('open_message', {
                id: message.id,
              })} />
              <Button.Confirm
                icon="trash"
                onClick={() => act('delete_message', {
                id: message.id,
              })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )}
  </Section>
  );
};

export const RequestsConsoleRequest = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Create Request">
      <DepartmentDropdown />
      <Button
        content="Normal Priority"
        selected={data.messagePriority === 1}
        onClick={() => act("set_message_priority", {
          priority: 1
        })} />
      <Button
        content="High Priority"
        selected={data.messagePriority === 2}
        onClick={() => act("set_message_priority", {
          priority: 2
        })} />
      <Button
        content="Extreme Priority"
        color="bad"/>
      <TextArea
        height="200px"
        mb={1}
        value={data.message}
        onChange={(e, value) => act("set_message", {
          message: value
        })} />
      <Button.Confirm
        icon="check"
        color="good"
        content="Send Message"
        onClick={() => act("send_message")} />
    </Section>
  );
};

export const RequestsConsoleEmergencies = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Emergencies"
        >
    </Section>
  );
};

export const DepartmentDropdown = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          width="75%"
          selected={data.recipientDepartment ? data.recipientDepartment : "Recipient Department..."}
          options={data.assistanceDepartments}
          onSelected={sel => act("set_message_department", {
            department: sel,
          })} />
      </Stack.Item>
    </Stack>
  );
};

export const RequestsConsoleMessage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    activeMessage
  } = data;
  if (!activeMessage) {
    return <RequestsConsoleMessageList />;
  }
  return (
    <Section
      title={"Request From: " + activeMessageSource}>
      Recieved: Time
    </Section>
  );
};
